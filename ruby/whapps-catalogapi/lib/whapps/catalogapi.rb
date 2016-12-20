require "whapps/catalogapi/version"
require 'net/http'
require 'securerandom'
require 'time'
require 'openssl'
require 'base64'
require 'json'

# docs?
class Whapps
  class CatalogAPI
    # Right now this is for API version 1
    API_VERSION = 'v1'
    attr_accessor :endpoint, :secret_key
    
    def initialize(endpoint:, secret_key:)
      self.endpoint = endpoint
      self.secret_key = secret_key
    end

    # Generate the creds we use to make the call.
    # See the documentation on the catalogapi.com portal for details
    def generate_credentials(method:) 
      uuid = SecureRandom.uuid;
      datetime = Time.now.utc.iso8601
      digest = OpenSSL::Digest.new('sha1')
      checksum = Base64.strict_encode64(OpenSSL::HMAC.digest(digest, @secret_key, method + uuid + datetime))
      return { 'creds_uuid' => uuid, 'creds_datetime' => datetime, 'creds_checksum' => checksum }
    end

    # Pass the creds on any get request we want to make
    def get_request(method:,query: {})
      credentials = generate_credentials(method: method);
      params = query.merge(credentials)
      uri = URI(@endpoint + '/' + API_VERSION + '/rest/' + method + '/')
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
      if (response.kind_of? Net::HTTPSuccess)
        return JSON.parse(response.body)
      else
        raise StandardError, response
      end 
    end

    # Returns true or false based on if redemption has been activated for the passed 
    # endpoint and secret key.
    def redemption_active?
      response = get_request(method: 'redemption_active')
      if response['redemption_active_response']['redemption_active_result'].to_i == 1
        return true
      else
        return false
      end
    end

    # List the sockets made available for the account. 
    def list_available_catalogs
      response = get_request(method: 'list_available_catalogs')
      return response['list_available_catalogs_response']['list_available_catalogs_result']['domain']['sockets']['Socket']
    end

    # Get the tree of catalog categories for the selected socket
    def catalog_breakdown(socket:)
      response = get_request(method: 'catalog_breakdown', query: { 'socket_id' => socket })
      return response['catalog_breakdown_response']['catalog_breakdown_result']['categories']['Category']
    end

    # Search the catalog on the selected socket
    def search_catalog(socket:, search: nil, category_id: nil, min_points: nil, max_points: nil,
                       per_page: 10, page: 1, sort: 'rank asc')
      search_args = { 'socket_id' => socket, 'search' => search, 'category_id' => category_id, 'min_points' => min_points,
                      'max_points' => max_points, 'per_page' => per_page, 'page' => page, 'sort' => sort }
      response = get_request(method: 'search_catalog', query: search_args)
      return response['search_catalog_response']['search_catalog_result']['items']['CatalogItem']      
    end

    def view_item(socket:, catalog_item_id:)
      response = get_request(method: 'view_item', query: { 'socket_id' => socket, 'catalog_item_id' => catalog_item_id })
      return response['view_item_response']['view_item_result']['item']
    end

    def cart_add_item(socket:, catalog_item_id:, user:, option_id: nil, quantity: 1)
      response = get_request(method: 'cart_add_item',
                             query: { 'socket_id' => socket,
                                      'catalog_item_id' => catalog_item_id,
                                      'external_user_id' => user,
                                      'option_id' => option_id,
                                      'quantity' => quantity })
      return response['cart_add_item_response']['cart_add_item_result']['description']
    end

    def cart_remove_item(socket:, catalog_item_id:, user:, option_id: nil)
      response = get_request(method: 'cart_set_item_quantity',
                             query: { 'socket_id' => socket,
                                      'catalog_item_id' => catalog_item_id,
                                      'option_id' => option_id,
                                      'quantity' => 0,
                                      'external_user_id' => user })
      return response['cart_set_item_quantity_response']['cart_set_item_quantity_result']['description']
    end

    def cart_set_item_quantity(socket:, catalog_item_id:, quantity:, user:, option_id: nil)
      response = get_request(method: 'cart_set_item_quantity',
                             query: { 'socket_id' => socket,
                                      'catalog_item_id' => catalog_item_id,
                                      'option_id' => option_id,
                                      'quantity' => quantity,
                                      'external_user_id' => user })
      return response['cart_set_item_quantity_response']['cart_set_item_quantity_result']['description']
    end

    def cart_empty(socket:, user:)
      response = get_request(method: 'cart_empty',
                             query: { 'socket_id' => socket,
                                      'external_user_id' => user })
      return response['cart_empty_response']['cart_empty_result']['description']
    end

    # Set the address that you wish the items to be shipped to, along with the user's 
    # name and contact information.
    #
    # Required arguments 
    # * +socket+:: *Integer* The socket ID
    # * +user+:: *String* The ID of the user making the request from your system
    # * +first_name+:: *String* The user's first name
    def cart_set_address(socket:, user:, first_name:, last_name:,
                         address_1:, address_2: nil, address_3: nil, city:,
                         state_province:, postal_code:, country:,
                         email:, phone_number: nil)
      response = get_request(method: 'cart_set_address', 
                             query: { 'socket_id' => socket, 'external_user_id' => user, 'first_name' => first_name,
                                      'last_name' => last_name, 'address_1' => address_1, 'address_2' => address_2,
                                      'address_3' => address_3, 'city' => city, 'state_province' => state_province,
                                      'postal_code' => postal_code, 'country' => country, 'email' => email,
                                      'phone_number' => phone_number })
      return response['cart_set_address_response']['cart_set_address_result']
    end

    def cart_validate(socket:, user:, locked: 1)
      response = get_request(method: 'cart_validate',
                             query: { 'socket_id' => socket,
                                      'locked' => locked,
                                      'external_user_id' => user })
      return response['cart_validate_response']['cart_validate_result']['description']
    end

    def cart_unlock(socket:, user:)
      response = get_request(method: 'cart_unlock',
                             query: { 'socket_id' => socket,
                                      'external_user_id' => user })
      return response['cart_unlock_response']['cart_unlock_result']['description']
    end

    def cart_view(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      clean_cart = response['cart_view_response']['cart_view_result']
      creds = clean_cart.delete('credentials')
      items = clean_cart['items'].delete('CartItem')
      clean_cart['items'] = items
      return clean_cart
    end

    def cart_needs_address?(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      if response['cart_view_response']['cart_view_result']['needs_address'].to_i == 1
        return true
      else
        return false
      end
    end

    def cart_is_locked?(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      if response['cart_view_response']['cart_view_result']['locked'].to_i == 1
        return true
      else
        return false
      end
    end

    def cart_is_valid?(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      if response['cart_view_response']['cart_view_result']['is_valid'].to_i == 1
        return true
      else
        return false
      end
    end

    def cart_has_item_errors?(socket:, user:)
      response = get_request(method: 'cart_view', query: { 'socket_id' => socket, 'external_user_id' => user })
      if response['cart_view_response']['cart_view_result']['has_item_errors'].to_i == 1
        return true
      else
        return false
      end
    end

    def cart_order_place(socket:, user:, cart_version: nil)
      response = get_request(method: 'cart_order_place',
                             query: { 'socket_id' => socket,
                                      'cart_version' => cart_version,   
                                      'external_user_id' => user })
      return response['cart_order_place_response']['cart_order_place_result']['order_number']
    end

    def order_place(socket:, user:, order:)
      raise StandardError, 'This method has not yet been completed' 
    end

    def order_list(user:, per_page: 10, page: 1)
      response = get_request(method: 'order_list',
                             query: { 'external_user_id' => user })
      clean_list = response['order_list_response']['order_list_result']
      creds = clean_list.delete('credentials')
      orders = clean_list['orders'].delete('OrderSummary')
      clean_list['orders'] = orders
      return clean_list
    end

    def order_track(order_number:)
      response = get_request(method: 'order_track',
                             query: { 'order_number' => order_number })
      return response['order_track_response']['order_track_result']
    end

    private :generate_credentials, :get_request
  end
end 
