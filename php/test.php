<?php
require_once 'catalogapi.php';

// usage: php test.php -d testco -k 'mysecretkey' -s 'socket_id'

$options = getopt("d:k:s:");

$catalogapi = new CatalogAPI($options["d"], $options["k"]);
$socket_id = $options["s"];

$catalogs_ref = $catalogapi->list_available_catalogs();

if ($catalogs_ref == NULL || $catalogs_ref == "")
{
    print $catalogapi->error . "\n";
}
else
{
    // print "DUMP: " . var_dump($catalogs_ref);

    // // this is a BIT verbose ;)
    // print "Account: " . $catalogs_ref["domain"]["account_name"] . "\n";

    // $breakdown = $catalogapi->catalog_breakdown($socket_id);
    // print var_dump($breakdown);

    // $search = $catalogapi->search_catalog($socket_id, array( search => "" ));
    // print var_dump($search);

    // $catalog_item_id = $search["items"]["CatalogItem"][0]["catalog_item_id"] . "\n";
    $catalog_item_id = 2386886;

    // $view_item = $catalogapi->view_item($socket_id, $catalog_item_id);
    // print var_dump($view_item);

    $address_set = array(
      socket_id => $socket_id,
      external_user_id => 'johndoe123',
      first_name => 'John',
      last_name => 'Doe',
      address_1 => '201 East Fourth Street',
      address_2 => 'Suite 1850',
      city => 'Cincinnati',
      state_province => 'OH',
      postal_code => '45202',
      country => 'US',
      email => 'johndoe123@example.com',
      phone_number => '123-555-6789'
    );

    $add_item_args = array(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        catalog_item_id => $catalog_item_id,
        quantity => 1,
        option_id => NULL
    );

    $cart_set_address = $catalogapi->cart_set_address($address_set);
    print "{$cart_set_address['description']}\n";

    $cart_add_item = $catalogapi->cart_add_item($add_item_args);
    print "{$cart_add_item['description']}\n";

    $add_item_args[quantity] = 2;

    $cart_set_item_quantity = $catalogapi->cart_set_item_quantity($add_item_args);
    print "{$cart_set_item_quantity['description']}\n";


    $catalog_args = array(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        locked => 0
    );

    $error = $catalogapi->cart_validate($catalog_args);

    if ($error)
    {
        echo "the cart is invalid: $error";
    }
    else
    {
        print "the cart is valid\n";
    }


    // unset($add_item_args[quantity]);
    //
    // $cart_remove_item = $catalogapi->cart_remove_item($add_item_args);
    // print "{$cart_remove_item['description']}\n";
    //
    // unset($add_item_args[catalog_item_id]);
    //
    // $cart_empty = $catalogapi->cart_empty($add_item_args);
    // print "{$cart_empty['description']}\n";


}

?>
