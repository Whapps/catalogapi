<?php

// THIS MODULE IS NOT YET COMPLETE

class CatalogAPI
{
    // subdomain: the first part of your SUBDOMAIN.dev.catalogapi.com domain
    // secret key: the secret key you were given
    // is_prod, FALSE for dev, TRUE for production (you must you your prod key if this is TRUE)
    function __construct($sub_domain, $secret_key, $is_prod = FALSE)
    {
        $this->sub_domain = $sub_domain;
        $this->secret_key = $secret_key;
        $this->is_prod = $is_prod;
        $this->error = NULL;
        $this->server_error = "";
        $this->client_error = "";
    }



    /*
        Function: redemption_active

        Returns 1 if redemption is active (i.e. production orders can be placed.)
        Returns 0 if not.
    */
    function redemption_active()
    {
        $response = $this->_make_request("redemption_active");
        return $response["redemption_active_response"]["redemption_active_result"];
    }



    /*
        Function: list_available_catalogs
        $list_available_catalogs_response = $api->list_available_catalogs();

        $domain = $catalogs_ref["list_available_catalogs_response"]["list_available_catalogs_result"]["domain"];
        print "The following sockets are available for the {$domain['account_name']} account.\n";

        foreach($domain["sockets"]["Socket"] as $socket)
        {
            print "got socket: {$socket['socket_name']}\n";
        }
    */
    function list_available_catalogs()
    {
        $response = $this->_make_request("list_available_catalogs");
        $ref = $response["list_available_catalogs_response"]["list_available_catalogs_result"];
        $this->_validate_response($ref["credentials"]);
        return $ref;
    }



    /*
        Function: catalog_breakdown

        function process_category($category, $depth)
        {
            print str_repeat("\t", $depth) . "found category: {$category['name']} \n";

            foreach($category["children"]["Category"] as $child)
            {
                process_category($child, $depth++);
            }
        }

        $args = array(
            "socket_id" => $socket_id,
            "is_flat" => 0
        );

        $breakdown = $api->catalog_breakdown($args);

        foreach($breakdown["categories"]['Category'] as $category)
        {
            process_category($category, 0);
        }

    */
    function catalog_breakdown($args)
    {
        $response = $this->_make_request("catalog_breakdown", $args);
        $ref = $response["catalog_breakdown_response"]["catalog_breakdown_result"];
        $this->_validate_response($ref["credentials"]);
        return $ref;
    }



    /*
        Function: search_catalog

        Check the catalogapi.com documentation for a full list of search parameters.


        $args = array(
            "socket_id" => $socket_id,
            "search" => 'ipod'
        );

        $search_catalog_response = $api->search_catalog($args);

        foreach($search_catalog_response["items"]['CatalogItem'] as $item)
        {
            print "found item: {$item['name']}\n";
        }
    */
    function search_catalog($args)
    {
        $response = $this->_make_request("search_catalog", $args);
        $ref = $response["search_catalog_response"]["search_catalog_result"];
        $this->_validate_response($ref["credentials"]);
        return $ref;
    }



    /*
        Function: view_item

        $args = array(
            "socket_id" => $socket_id,
            "catalog_item_id" => $catalog_item_id
        );

        $view_item_response = $api->view_item($args);

        $item = $view_item_response["item"];

        print "found item: {$item['name']}\n{$item['description']}";
    */
    function view_item($args)
    {
        $response = $this->_make_request("view_item", $args);
        $ref = $response["view_item_response"]["view_item_result"];
        $this->_validate_response($ref["credentials"]);

        $item = &$ref["item"];
        $tags = $item["tags"];
        unset($item["tags"]);
        $item["tags"] = $tags["string"] ? $tags["string"] : array();

        $categories = $item["categories"];
        unset($item["categories"]);
        $item["categories"] = $categories["integer"] ? $categories["integer"] : array();

        return $ref;
    }

    /*
        Section: CART METHODS

        Carts provide a way to build an order through a REST interface.
        You can add and remove items, set a shipping address, and place an order.
        These methods explain how.
    */

    /*
        Function: cart_add_item

        Adds items to the cart.

        $args = array(
            "socket_id" => $socket_id,
            "catalog_item_id" => $catalog_item_id,
            "external_user_id" => 'johndoe123',
            "option_id" => 123, # This is required for items that have options
            "quantity" => 1
        );

        $cart_add_item_response = $api->cart_add_item($args);

        print "{$cart_add_item_response['description']}\n";
    */
    function cart_add_item($args)
    {
        $response = $this->_make_request("cart_add_item", $args);
        $ref = $response["cart_add_item_response"]["cart_add_item_result"];
        $this->_validate_response($ref["credentials"]);

        return $ref;
    }



    /*
        Function: cart_remove_item

        Removes items from the cart.

        $args = array(
            "socket_id" => $socket_id,
            "catalog_item_id" => $catalog_item_id,
            "external_user_id" => 'johndoe123',
            "option_id" => 123 # This is required for items that have options
        );

        $cart_remove_item_response = $api->cart_remove_item($args);

        print "{$cart_remove_item_response['description']}\n";
    */
    function cart_remove_item($args)
    {
        $response = $this->_make_request("cart_remove_item", $args);
        $ref = $response["cart_remove_item_response"]["cart_remove_item_result"];
        $this->_validate_response($ref["credentials"]);

        return $ref;
    }



    /*
        Function: cart_set_item_quantity

        Adds items to the cart. The quantity passed to this call overrides the quantity of a duplicate item.

        $args = array(
            "socket_id" => $socket_id,
            "catalog_item_id" => $catalog_item_id,
            "external_user_id" => 'johndoe123',
            "quantity" => 2,
            "option_id" => 123 # This is required for items that have options
        );

        $cart_set_item_quantity_response = $api->cart_set_item_quantity($args);

        print "{$cart_set_item_quantity_response['description']}\n";
    */
    function cart_set_item_quantity($args)
    {
        $response = $this->_make_request("cart_set_item_quantity", $args);
        $ref = $response["cart_set_item_quantity_response"]["cart_set_item_quantity_result"];
        $this->_validate_response($ref["credentials"]);

        return $ref;
    }



    /*
        Function: cart_empty

        Removes all items in the cart.

        $args = array(
            "socket_id" => $socket_id,
            "external_user_id" => 'johndoe123'
        );

        $cart_empty_response = $api->cart_empty($args);

        print "{$cart_empty_response['description']}\n";
    */
    function cart_empty($args)
    {
        $response = $this->_make_request("cart_empty", $args);
        $ref = $response["cart_empty_response"]["cart_empty_result"];
        $this->_validate_response($ref["credentials"]);

        return $ref;
    }



    /*
        Function: cart_set_address

        Adds a shipping address to the cart

        $args = array(
          socket_id => $socket_id,
          external_user_id => 'johndoe123',
          first_name => 'John',
          last_name => 'Doe',
          address_1 => '123 Test St.',
          address_2 => 'Apt. B',
          city => 'Cincinnati',
          state_province => 'OH',
          postal_code => '00000',
          country => 'US',
          email => 'johndoe123@example.com',
          phone_number => '123-555-6789'
        );

        $cart_set_address_response = $api->cart_set_address($args);

        print "{$cart_set_address_response['description']}\n";
    */
    function cart_set_address($args)
    {
        $response = $this->_make_request("cart_set_address", $args);
        $ref = $response["cart_set_address_response"]["cart_set_address_result"];
        $this->_validate_response($ref["credentials"]);

        return $ref;
    }



    /*
        Function: cart_validate

        Validates the address and items in the cart.
        You should call this method just before placing an order to make sure that the order will not be rejected.

        This method works a bit differently than the others.
        It will return undef if the cart is valid,
        otherwise it returns the error message string.

        $args = array(
          socket_id => $socket_id,
          external_user_id => 'johndoe123',
          locked =>0
        );

        $error = $api->cart_validate($args);

        if ($error)
        {
            warn "the cart is invalid: $error";
        }
        else
        {
            print "the cart is valid\n";
        }
    */
    function cart_validate($args)
    {
        $args["die_on_default"] = 0;
        $response = $this->_make_request("cart_validate", $args);
        $ref = $response["cart_set_address_response"]["cart_set_address_result"];
        $this->_validate_response($ref["credentials"]);

        return $ref;
    }


    function _make_request($method, $args = array())
    {
        $data = NULL;
        $this->error = NULL;
        $this->_reset_errors();

        $die_on_fault;

        if(isset($args[die_on_fault]))
        {
            unset($args[die_on_fault]);
            $die_on_fault = TRUE;
        }

        $url = "https://" . $this->sub_domain . ($this->is_prod ? ".prod" : ".dev") . ".catalogapi.com/v1/rest/$method/?";
        $url .= $this->_generate_checksum_args($method);
        foreach ($args as $key => $value)
        {
            $url .= "&$key=" . rawurlencode($value);
        }

        // print("URL:" . $url . "\n");

        $ch = curl_init( $url );

        curl_setopt($ch,CURLOPT_TIMEOUT,30);
        curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);

        $result = curl_exec($ch);

        try
        {
            $data = json_decode($result, true); // true here returns arrays instead of objects
        }
        catch (Exception $ex)
        {
            die("invalid response: " . $ex->getMessage());
        }

        if(!curl_errno($ch) || !$die_on_fault)
        {
            curl_close($ch);
            return $data;
        }
        else
        {
            if($data["Fault"]["detail"])
            {
                echo $data["Fault"]["detail"];
            }

            if($data["Fault"]["faultcode"])
            {
                $this->client_error = $data["Fault"]["faultstring"];
            }
            else
            {
                $this->server_error = $data["Fault"]["faultstring"];
            }

            die($data["Fault"]["faultcode"] . ": " . $data["Fault"]["faultstring"] . "\n");
        }

    }

    function has_error()
    {
        return ($this->server_error || $this->client_error);
    }

    function _reset_errors()
    {
        $this->server_error = "";
        $this->client_error = "";
        return;
    }

    function _generate_checksum_args($method)
    {
        $message_id = $this->_get_guid();

        $now_datetime = new DateTime('NOW', new DateTimeZone('UTC'));
        $now_string = $now_datetime->format('Y-m-d H:i:s');

        #print "NOW: $now_string\n";

        $digest_string = "$method$message_id$now_string";

        $checksum = base64_encode( hash_hmac("sha1", $digest_string, $this->secret_key, TRUE) );

        return "creds_datetime=" . rawurlencode($now_string)
            . "&creds_uuid=" . rawurlencode($message_id)
            . "&creds_checksum=" . rawurlencode($checksum);
    }

    function _get_guid()
    {
        if (function_exists('com_create_guid'))
        {
            return substr(com_create_guid(), 1, 36);
        }
        else
        {
            mt_srand((double)microtime()*10000); //optional for php 4.2.0 and up.
            $charid = strtoupper(md5(uniqid(rand(), true)));
            $hyphen = chr(45); // "-"
            $uuid = substr($charid, 0, 8).$hyphen
                .substr($charid, 8, 4).$hyphen
                .substr($charid,12, 4).$hyphen
                .substr($charid,16, 4).$hyphen
                .substr($charid,20,12);
            return $uuid;
        }
    }

    function _validate_response($creds)
    {

        $digest_string = $creds["method"].$creds["uuid"].$creds["datetime"];
        $their_checksum = $creds["checksum"];
        $our_checksum = base64_encode( hash_hmac("sha1", $digest_string, $this->secret_key, TRUE) );

        if($their_checksum != $our_checksum)
        {
            echo "the returned checksum is invalid";
        }

        return;
    }
}

?>
