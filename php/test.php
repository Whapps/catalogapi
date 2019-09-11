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
    // $order_number = '9658-02828-19455-0001';

    // $view_item = $catalogapi->view_item(array(socket_id => $socket_id, catalog_item_id => $catalog_item_id));
    // print var_dump($view_item);

    $add_item_args = array(
        catalog_item_id => $catalog_item_id,
        quantity => 1,
        currency => "USD",
        catalog_price => 25.00,
        option_id => NULL
    );

    $args = array(
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
        phone_number => '123-555-6789',
        items => array(
            $add_item_args
        )
    );


    $order_number = $catalogapi->order_place($args);
    print "the order was created with the order_number: $order_number\n";



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
