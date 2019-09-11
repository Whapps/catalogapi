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
          locked => 0
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
        $args["die_on_default"] = 1;
        $response = $this->_make_request("cart_validate", $args);

        if($response["Fault"])
        {
            if($response["Fault"]["faultcode"] == 'Client.APIError')
            {
                return $response["Fault"]["faultstring"];
            }
            else
            {
                die($response["Fault"]["faultcode"] . ": " . $response["Fault"]["faultstring"] . "\n");
            }
        }
        else
        {
            $ref = $response["cart_validate_response"]["cart_validate_result"];
            $this->_validate_response($ref["credentials"]);
            return;
        }
    }



    /*
        Function: cart_unlock

        Adds a shipping address to the cart

        $args = array(
          socket_id => $socket_id,
          external_user_id => 'johndoe123'
        );

        $cart_unlock_response = $api->cart_unlock($args);

        print "{$cart_unlock_response['description']}\n";
    */
    function cart_unlock($args)
    {
        $response = $this->_make_request("cart_unlock", $args);
        $ref = $response["cart_unlock_response"]["cart_unlock_result"];
        $this->_validate_response($ref["credentials"]);

        return $ref;
    }



    /*
        Function: cart_view

        Returns the current address and items in the cart.

        This method can also be used to validate the cart.
        While you can use the cart_validate method for this purpose,
        cart_validate will simply return a single error message if the cart is invalid.
        You can use the results from the cart_view method to find all of
        the problems with a cart in order to display helpful feedback to the user.

        In order for a cart to be vaild, it must have:

        - An address
        - At least one item
        - All items must be available (as specified through the is_available field on each item)
        - All of the item's cart_price values must be less than or equal to the catalog_price values

        $args = array(
            socket_id => $socket_id,
            external_user_id => 'johndoe123'
        );

        $cart_view_response = $api->cart_view($args);

        if ( !$cart_view_response["first_name"] )
        {
            echo "The cart must have an address to place an order.";
        }
        else
        {
            echo "Viewing cart for {$cart_view_response['first_name']} {$cart_view_response['last_name']}\n";
        }

        echo "cart version: {$cart_view_response['cart_version']}" . "\n";
        echo "cart is locked?:" . ($cart_view_response['locked'] ? 'yes' : 'no') . "\n";

        # note that this code will only show a single error
        # when there are multiple quantities of the same item

        $errors = array();
        $has_item = 0;
        $items_list = &$cart_view_response["items"]["CartItem"];
        foreach($items_list as &$cart_item)
        {
            $has_item = 1;
            if(!$cart_item["is_available"])
            {
                $errors[] = array($cart_item[name] => "item is no longer available");
            }
            if ($cart_item["catalog_price"] > $cart_item["cart_price"])
            {
                $errors[] = array($cart_item[name] => "the item has gone up in price, please remove then re-add the item");
            }
        }
        if (!$has_item)
        {
            echo "The must contain at least one item to place an order.\n";
        }
        if (count($errors))
        {
            foreach($errors as $key => $value)
            {
                echo "There is a problem with the item: {$key} - {$value}\n";
            }
        }

        As a convenience, all of the cart errors will be in $cart_view_response["errors"].

        if ($cart_view_response["errors"])
        {
            echo "The cart contains errors.\n";

            foreach($cart_view_response["errors"] as $error)
            {
                echo $error["error"] . "\n";

                # you could also automatically remove invalid items here...
                if ($error["catalog_item_id"])
                {
                    $remove_item_args = array(
                        socket_id => $socket_id,
                        external_user_id => 'johndoe123',
                        catalog_item_id => $error["catalog_item_id"],
                        option_id => $error["option_id"]
                    );
                    $api->cart_remove_item($remove_item_args);
                }
            }
        }
        else
        {
            print "The cart is valid.\n";
        }
    */
    function cart_view($args)
    {
        $response = $this->_make_request("cart_view", $args);
        $ref = $response["cart_view_response"]["cart_view_result"];
        $this->_validate_response($ref["credentials"]);

        $errors = array();

        $total_points = 0;
        $total_cost = 0;

        $has_item = 0;
        $items_list = &$ref["items"]["CartItem"];
        foreach($items_list as &$cart_item)
        {
            $item_is_valid = 1;

            if(!$cart_item["is_available"])
            {
                $errors[] = array(
                    error => "Item is not longer available: {$cart_item['name']}",
                    catalog_item_id => $cart_item["catalog_item_id"],
                    option_id => $cart_item["option_id"]
                );
                $item_is_valid = 0;
            }

            if($cart_item["catalog_price"] > $cart_item["cart_price"])
            {
                $errors[] = array(
                    error => "The item has gone up in price since it was added to the cart, please remove then re-add the item: {$cart_item['name']}",
                    catalog_item_id => $cart_item["catalog_item_id"],
                    option_id => $cart_item["option_id"]
                );
                $item_is_valid = 0;
            }

            $has_item = 1;
            $cart_item["item_is_valid"] = $item_is_valid;

            $total_points += ( $cart_item["points"] * $cart_item["quantity"] );
            $total_cost += ( $cart_item["catalog_price"] * $cart_item["quantity"] );
        }

        $ref["total_points"] = $total_points;
        $ref["total_cost"] = $total_cost;

        if(!$has_item)
        {
            $errors[] = "The cart must contain at least one item to place an order";
        }

        $ref["has_item_errors"] = count($errors) ? 1 : 0;

        if(!$ref["first_name"])
        {
            $errors[] = array(
              error => "The cart must have an address to place an order"
            );
        }

        $ref["is_valid"] = count($errors) ? 0 : 1;

        $ref["errors"] = $errors;

        return $ref;
    }



    /*
        Function: cart_order_place

        Adds a shipping address to the cart

        $args = array(
          socket_id => $socket_id,
          external_user_id => 'johndoe123',
          cart_version => $cart_version # optional - this is the cart_version from the cart_view method
        );

        $order_number = $api->cart_order_place($args);

        print "the order was created with the order_number: {$order_number}\n";
    */
    function cart_order_place($args)
    {
        $response = $this->_make_request("cart_order_place", $args);
        $ref = $response["cart_order_place_response"]["cart_order_place_result"];
        $this->_validate_response($ref["credentials"]);

        return $ref["order_number"];
    }



    /*
        Section: ORDER METHODS
    */



    function _make_request($method, $args = array())
    {
        $data = NULL;
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

        $meta = array();
        if(isset($args[meta]))
        {
            foreach($args[meta] as $key => $value)
            {
                $value = mb_detect_encoding($value, 'UTF-8') ? utf8_encode($value) : $value;

                if(substr($key, 0, strlen('x-meta')) === 'x-meta')
                {
                    $meta[] = "{$key}: {$value}";
                }
                else
                {
                    $meta[] = "x-meta-{$key}: {$value}";
                }
            }
        }

        $ch = curl_init( $url );

        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $meta);

        $result = curl_exec($ch);
        $curl_errno = curl_errno($ch);
        curl_close($ch);

        try
        {
            $data = json_decode($result, true); // true here returns arrays instead of objects
        }
        catch (Exception $ex)
        {
            die("invalid response: " . $ex->getMessage());
        }

        if(!$curl_errno || !$die_on_fault)
        {
            return $data;
        }
        else
        {
            if($data["Fault"]["detail"])
            {
                echo $data["Fault"]["detail"];
            }
            if(strpos($data["Fault"]["faultcode"], 'Client'))
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

    function _create_order($order_args = array())
    {
        $data = NULL;
        $this->_reset_errors();

        $method = 'order_place';
        $creds = $this->_generate_creds($method);

        $order_ref = array(
            order_place => array(
                order_place_request => $order_args
            )
        );

        $order_ref[order_place][order_place_request][credentials] = array (
            method => $method,
            checksum => $creds[creds_checksum],
            datetime => $creds[creds_datetime],
            uuid => $creds[creds_uuid]
        );

        $url = "https://" . $this->sub_domain . ($this->is_prod ? ".prod" : ".dev") . ".catalogapi.com/v1/json/$method/";

        $payload = json_encode($order_ref);

        $ch = curl_init( $url );

        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLINFO_HEADER_OUT, 1);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);

        // Set HTTP Header for POST request
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            'Content-Type: application/json',
            'Content-Length: ' . strlen($payload))
        );

        $result = curl_exec($ch);
        $curl_errno = curl_errno($ch);
        curl_close($ch);

        try
        {
            $data = json_decode($result, true); // true here returns arrays instead of objects
        }
        catch (Exception $ex)
        {
            die("invalid response: " . $ex->getMessage());
        }

        if(!$curl_errno)
        {
            return $data;
        }
        else
        {
            if($data["Fault"]["detail"])
            {
                echo $data["Fault"]["detail"];
            }
            if(strpos($data["Fault"]["faultcode"], 'Client'))
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

    function _generate_creds($method)
    {
        $message_id = $this->_get_guid();

        $now_datetime = new DateTime('NOW', new DateTimeZone('UTC'));
        $now_string = $now_datetime->format('Y-m-d H:i:s');


        $digest_string = "$method$message_id$now_string";

        $checksum = base64_encode( hash_hmac("sha1", $digest_string, $this->secret_key, TRUE) );

        return array(
            creds_datetime => $now_string,
            creds_uuid => $message_id,
            creds_checksum => $checksum
        );
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
