require 'whapps/catalogapi/version'
require 'net/http'
require 'securerandom'
require 'time'
require 'openssl'
require 'base64'
require 'json'

# Placeolder
module Whapps
  # Whapps::CatalogAPI - Interface to the catalogapi.com API
  # For more informaiton on the catalogapi.com service, please check your documentation portal
  class CatalogAPI
    # Right now this is for API version 1, dont let it be changed
    API_VERSION = 'v1'.freeze
    attr_accessor :endpoint, :secret_key

    def initialize(endpoint:, secret_key:)
      self.endpoint = endpoint
      self.secret_key = secret_key
      @digester = OpenSSL::Digest.new('sha1')
    end

    # Generate the creds we use to make the call.
    # See the documentation on the catalogapi.com portal for details
    def generate_credentials(method:)
      uuid = SecureRandom.uuid
      datetime = Time.now.utc.iso8601
      checksum = Base64.strict_encode64(OpenSSL::HMAC.digest(@digester, @secret_key, method + uuid + datetime))
      { 'creds_uuid' => uuid, 'creds_datetime' => datetime, 'creds_checksum' => checksum }
    end

    # make sure if we get creds back that they are valid
    def validate_response_credentails(credentials:)
      checksum = Base64.strict_encode64(
        OpenSSL::HMAC.digest(@digester,
                             @secret_key,
                             credentials['method'] + credentials['uuid'] + credentials['datetime'])
      )
      raise StandardError, 'Response checksum mismatch' unless credentials['checksum'] == checksum
    end

    # Pass the creds on any get request we want to make
    def get_request(method:, query: {})
      credentials = generate_credentials(method: method)
      params = query.merge(credentials)
      uri = URI(@endpoint + '/' + API_VERSION + '/rest/' + method + '/')
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)

      raise StandardError, response unless response.is_a? Net::HTTPSuccess

      # each call is wrapped in two hashes that mirror the method names (thanks spyne.io)
      # lets remove these instead of having to do so in every call
      parsed = JSON.parse(response.body)
      key_response = method + '_response'
      key_result   = method + '_result'

      # some calls return a checksum as well, lets valdate those
      if parsed[key_response][key_result].is_a?(Hash)
        credentials = parsed[key_response][key_result].delete('credentials')
        validate_response_credentails(credentials: credentials) if credentials.is_a?(Hash)
      end

      parsed[key_response][key_result]
    end

    # Returns true if the selected account has redemption activated.
    def redemption_active?
      response = get_request(method: 'redemption_active')
      return true if response.to_i == 1
      false
    end

    # List the sockets made available for the selected account.
    def list_available_catalogs
      response = get_request(method: 'list_available_catalogs')
      response['domain']['sockets']['Socket']
    end

    # Get the tree of catalog categories for the selected socket
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    def catalog_breakdown(socket:)
      response = get_request(method: 'catalog_breakdown', query: { 'socket_id' => socket })
      response['categories']['Category']
    end

    # Search the catalog on the selected socket.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    #
    # Optional arguments
    # * +search+:: *String* Search for the specified string in the catalog
    # * +category_id+:: *Integer* Search for results only under this category id
    # * +min_points+:: *Integer* Search for results that cost at least this many points
    # * +max_points+:: *Integer* Search for results that cost no more than this many points
    # * +per_page+:: *Integer* The number of results to show per page, defaults to 10
    # * +page+:: *Integer* The page number of results to show, defaults to 1
    # * +sort+:: *String* The sort order to use, see the portal docs for valid sort orders
    def search_catalog(socket:, search: nil, category_id: nil, min_points: nil, max_points: nil,
                       per_page: 10, page: 1, sort: 'rank asc')
      search_args = { 'socket_id' => socket, 'search' => search, 'category_id' => category_id,
                      'min_points' => min_points, 'max_points' => max_points, 'per_page' => per_page,
                      'page' => page, 'sort' => sort }
      response = get_request(method: 'search_catalog', query: search_args)
      response['items']['CatalogItem']
    end

    # View a specific item by ID.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +catalog_item_id+:: *Integer* The item ID to view
    def view_item(socket:, catalog_item_id:)
      response = get_request(method: 'view_item',
                             query:  { 'socket_id' => socket, 'catalog_item_id' => catalog_item_id })
      response['item']
    end

    # Add an item to the user's cart.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +catalog_item_id+:: *Integer* The item ID to view
    # * +user+:: *String* The ID of the user making the request from your system
    #
    # Optional arguments
    # * +option_id+:: *Integer* The option ID (if present on the item)
    # * +quantity+:: *Integer* The quantity to add, defaults to 1
    def cart_add_item(socket:, catalog_item_id:, user:, option_id: nil, quantity: 1)
      response = get_request(method: 'cart_add_item',
                             query:  { 'socket_id'        => socket,
                                       'catalog_item_id'  => catalog_item_id,
                                       'external_user_id' => user,
                                       'option_id'        => option_id,
                                       'quantity'         => quantity })
      response['description']
    end

    # Remove an item from the user's cart.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +catalog_item_id+:: *Integer* The item ID to view
    # * +user+:: *String* The ID of the user making the request from your system
    #
    # Optional arguments
    # * +option_id+:: *Integer* The option ID (if present on the item)
    def cart_remove_item(socket:, catalog_item_id:, user:, option_id: nil)
      response = get_request(method: 'cart_set_item_quantity',
                             query:  { 'socket_id'        => socket,
                                       'catalog_item_id'  => catalog_item_id,
                                       'option_id'        => option_id,
                                       'quantity'         => 0,
                                       'external_user_id' => user })
      response['description']
    end

    # Set the quantity of an item already in the cart
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +catalog_item_id+:: *Integer* The item ID to view
    # * +user+:: *String* The ID of the user making the request from your system
    # * +quantity+:: *Integer* The quantity to add, defaults to 1
    #
    # Optional arguments
    # * +option_id+:: *Integer* The option ID (if present on the item)
    def cart_set_item_quantity(socket:, catalog_item_id:, quantity:, user:, option_id: nil)
      response = get_request(method: 'cart_set_item_quantity',
                             query:  { 'socket_id'        => socket,
                                       'catalog_item_id'  => catalog_item_id,
                                       'option_id'        => option_id,
                                       'quantity'         => quantity,
                                       'external_user_id' => user })
      response['description']
    end

    # Empty the user's cart.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    def cart_empty(socket:, user:)
      response = get_request(method: 'cart_empty',
                             query:  { 'socket_id'        => socket,
                                       'external_user_id' => user })
      response['description']
    end

    # Set the address that you wish the items to be shipped to, along with the user's
    # name and contact information.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    # * +first_name+:: *String* The user's first name
    # * +last_name+:: *String* The user's last name
    # * +address_1+:: *String* The user's address line 1
    # * +city+:: *String* The user's city
    # * +state_province+:: *String* The user's state or province
    # * +postal_code+:: *String* The user's postal code
    # * +country+:: *String* The user's country code
    # * +email+:: *String* The user's email address
    #
    # Optional arguments
    # * +address_2+:: *String* The user's address line 2
    # * +address_3+:: *String* The user's address line 3
    # * +phone_number+:: *String* The user's phone number
    def cart_set_address(socket:, user:, first_name:, last_name:,
                         address_1:, address_2: nil, address_3: nil, city:,
                         state_province:, postal_code:, country:,
                         email:, phone_number: nil)
      get_request(method: 'cart_set_address',
                  query:  { 'socket_id' => socket, 'external_user_id' => user, 'first_name' => first_name,
                                      'last_name' => last_name, 'address_1' => address_1, 'address_2' => address_2,
                                      'address_3' => address_3, 'city' => city, 'state_province' => state_province,
                                      'postal_code' => postal_code, 'country' => country, 'email' => email,
                                      'phone_number' => phone_number })['description']
    end

    # Validate that the cart can be placed and has no errors like missing items.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    #
    # Optional arguments
    # * +locked+:: *Integer* Defaults to 1, but set to 0 to not lock the cart on validate
    def cart_validate(socket:, user:, locked: 1)
      response = get_request(method: 'cart_validate',
                             query:  { 'socket_id'        => socket,
                                       'locked'           => locked,
                                       'external_user_id' => user })
      response['description']
    end

    # Unlocks the cart so it can be edited again.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    def cart_unlock(socket:, user:)
      response = get_request(method: 'cart_unlock',
                             query:  { 'socket_id'        => socket,
                                       'external_user_id' => user })
      response['description']
    end

    # Fetch the user's current cart contents.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    def cart_view(socket:, user:)
      clean_cart = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      clean_cart.delete('credentials')
      items = clean_cart['items'].delete('CartItem')
      clean_cart['items'] = items
      clean_cart
    end

    # Returns true if the cart does not have an address information set.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    def cart_needs_address?(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      return true if response['needs_address'].to_i == 1
      false
    end

    # Returns true if the cart is currently locked.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    def cart_is_locked?(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      return true if response['locked'].to_i == 1
      false
    end

    # Returns true if the cart is valid and has no errors.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    def cart_is_valid?(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      return true if response['is_valid'].to_i == 1
      false
    end

    # Returns true if the cart contains items that have pricing or availability changes.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    def cart_has_item_errors?(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      return true if response['has_item_errors'].to_i == 1
      false
    end

    # Convert the current user cart into an order.  If you pass the cart version number the API
    # will make sure the cart has not been changed before trying to place the order.
    #
    # Required arguments
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    #
    # Optional arguments
    # * +cart_version+:: *String* The UUID cart version number
    def cart_order_place(socket:, user:, cart_version: nil)
      response = get_request(method: 'cart_order_place',
                             query:  { 'socket_id'        => socket,
                                       'cart_version'     => cart_version,
                                       'external_user_id' => user })
      response['order_number']
    end

    # List all orders the user specified has placed.
    #
    # Required arguments
    # * +user+:: *String* The ID of the user making the request from your system
    #
    # Optional arguments
    # * +per_page+:: *Integer* The number of results to show per page, defaults to 10
    # * +page+:: *Integer* The page number of results to show, defaults to 1
    def order_list(user:, per_page: 10, page: 1)
      clean_list = get_request(method: 'order_list',
                               query:  { 'external_user_id' => user, 'per_page' => per_page, 'page' => page })
      orders = clean_list['orders'].delete('OrderSummary')
      clean_list['orders'] = orders
      clean_list
    end

    # Get the order item and tracking information.
    #
    # Required arguments
    # * +order_number+:: *String* The order number you want tracking information for
    def order_track(order_number:)
      get_request(method: 'order_track',
                  query:  { 'order_number' => order_number })
    end

    private :generate_credentials, :get_request, :validate_response_credentails
  end
end
