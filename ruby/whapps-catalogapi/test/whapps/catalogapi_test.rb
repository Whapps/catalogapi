require 'test_helper'
require 'pp'

module Whapps
  class CatalogAPITest < Minitest::Test
    def setup
      @secret_key = ENV['API_KEY']
      @endpoint   = ENV['API_ENDPOINT']
      @socket     = ENV['API_SOCKET']
      @api        = Whapps::CatalogAPI.new(secret_key: @secret_key, endpoint: @endpoint)
      @api.cart_unlock(socket: @socket, user: 'test_user')
    end

    def test_that_it_has_a_version_number
      refute_nil ::Whapps::CatalogAPI::VERSION, 'Missing version number'
    end

    def test_constructor_works
      assert_instance_of Whapps::CatalogAPI, @api
    end

    def test_redemption_is_active
      assert @api.redemption_active?, 'Redemption active returned false'
    end

    def test_generate_credentials_is_private
      assert_raises NoMethodError do
        @api.generate_credentials(method: 'doesnt_matter')
      end
    end

    def test_get_request_is_private
      assert_raises NoMethodError do
        @api.get_request(method: 'doesnt_matter')
      end
    end

    def test_list_catalogs_contains_socket
      assert @api.list_available_catalogs.any? { |socket| socket['socket_id'].to_i == @socket.to_i },
             "Socket #{@socket} not found"
    end

    def test_catalog_navigation
      assert @api.catalog_breakdown(socket: @socket)[0].key?('category_id'),
             'No catalog navgiation was returned'
    end

    def test_catalog_search
      # just search in the first category for anything
      search_category = @api.catalog_breakdown(socket: @socket)[0]['category_id']
      assert @api.search_catalog(socket: @socket, category_id: search_category)[0].key?('catalog_item_id'),
             'No catalog search results were returned'
    end

    def test_view_item
      item_id = @api.search_catalog(socket: @socket)[0]['catalog_item_id']
      assert @api.view_item(socket: @socket, catalog_item_id: item_id).key?('catalog_item_id'),
             'No catalog view item results were returned'
    end

    def test_cart_add_item
      item_id = @api.search_catalog(socket: @socket)[0]['catalog_item_id']
      assert_equal @api.cart_add_item(socket: @socket, catalog_item_id: item_id, user: 'test_user'),
                   'Item quantity increased.',
                   'API did not return the expected string "Item quantity increased."'
    end

    def test_cart_remove_item
      item_id = @api.search_catalog(socket: @socket)[0]['catalog_item_id']
      @api.cart_add_item(socket: @socket, catalog_item_id: item_id, user: 'test_user')
      assert_equal @api.cart_remove_item(socket: @socket, catalog_item_id: item_id, user: 'test_user'),
                   'Item quantity set.',
                   'API did not return the expected string "Item quantity set."'
    end

    def test_cart_update_quantity
      # make sure we only use this second item in the result here to make sure the api response is what we expect
      item_id = @api.search_catalog(socket: @socket)[1]['catalog_item_id']
      @api.cart_add_item(socket: @socket, catalog_item_id: item_id, user: 'test_user')
      assert_equal @api.cart_set_item_quantity(socket: @socket,
                                      catalog_item_id: item_id, user: 'test_user', quantity: 2),
                   'Item quantity set.', 'API did not return the expected string "Item quantity set."'
    end

    def test_cart_empty
      assert_equal @api.cart_empty(socket: @socket, user: 'test_user'), 'Cart emptied.',
                   'API did not return the expected string "Cart emptied."'
    end

    def test_cart_set_address
      assert_equal @api.cart_set_address(socket: @socket, user: 'test_user', first_name: 'Test', last_name: 'User',
                                          address_1: '123 Test St.', city: 'Cincinnati', state_province: 'OH',
                                          postal_code: '45202', country: 'US', email: 'test@catalogapi.com'),
                   'Address Updated', 'API did not return the expected string "Address Updated"'
    end

    def test_cart_validate_and_unlock
      item_id = @api.search_catalog(socket: @socket)[2]['catalog_item_id']
      @api.cart_add_item(socket: @socket, catalog_item_id: item_id, user: 'test_user')
      @api.cart_set_address(socket: @socket, user: 'test_user', first_name: 'Test', last_name: 'User',
                            address_1: '123 Test St.', city: 'Cincinnati', state_province: 'OH', postal_code: '45202',
                          country: 'US', email: 'test@catalogapi.com')
      assert_equal @api.cart_validate(socket: @socket, user: 'test_user'),
                   'The cart is valid. The cart has been locked.',
                   'API did not return the expected string "The cart is valid. The cart has been locked."'
      assert @api.cart_is_locked?(socket: @socket, user: 'test_user'),
             'Cart should be locked, but it currently is not showing that'
      assert_equal @api.cart_has_item_errors?(socket: @socket, user: 'test_user'), false,
                   'Cart is showing item errors, but we just added so this should not be possible'
      # make sure to unlock it before we continue
      assert_equal @api.cart_unlock(socket: @socket, user: 'test_user'), 'The cart is unlocked.',
                   'API did not return the expected string "The cart is unlocked."'
    end

    def test_cart_view
      item_id = @api.search_catalog(socket: @socket)[1]['catalog_item_id']
      @api.cart_add_item(socket: @socket, catalog_item_id: item_id, user: 'test_user')
      assert @api.cart_view(socket: @socket, user: 'test_user')['items'].any? { |item|
        item['catalog_item_id'] == item_id
      },
             "Could not find item #{item_id}, which we just added"
    end

    def test_cart_needs_address
      @api.cart_set_address(socket: @socket, user: 'test_user', first_name: 'Test', last_name: 'User',
                            address_1: '123 Test St.', city: 'Cincinnati', state_province: 'OH',
                              postal_code: '45202', country: 'US', email: 'test@catalogapi.com')
      assert_equal @api.cart_needs_address?(socket: @socket, user: 'test_user'), false,
                   'Cart address was updated, but we still report that it requires an address'
    end
  end
end
