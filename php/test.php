<?php

error_reporting(E_ERROR | E_PARSE);

require_once 'catalogapi.php';

// usage: php test.php -d testco -k 'mysecretkey'

$options = getopt('d:k:');

$api = new CatalogAPI($options['d'], $options['k'], FALSE);

$list_available_catalogs_response = $api->list_available_catalogs();

$domain = $list_available_catalogs_response['domain'];

print "The following sockets are available for the {$domain['account_name']} account.\n";

$socket_id;
foreach($domain['sockets']['Socket'] as $socket)
{
    print "\t{$socket['socket_name']} (socket_id: {$socket['socket_id']})\n";
    $socket_id = $socket['socket_id'];
}

print "\nRetreiving categories for socket_id $socket_id...\n";

$args = array(
    socket_id => $socket_id,
    is_flat => 0
);

$catalog_breakdown_response = $api->catalog_breakdown($args);

function process_category($category, $depth)
{
    print str_repeat("\t", $depth) . "found category: {$category['name']} \n";

    foreach($category["children"]["Category"] as $child)
    {
        process_category($child, $depth++);
    }
}

foreach($catalog_breakdown_response["categories"]['Category'] as $category)
{
    process_category($category, 0);
}

print "\nSearching the catalog for the word \"card\"...\n";

$args = array(
    socket_id => $socket_id,
    search => 'card'
);

$search_catalog_response = $api->search_catalog($args);

$catalog_item;
foreach($search_catalog_response['items']['CatalogItem'] as $item)
{
    print "\tFound match: {$item['name']}\n";
    $catalog_item = $item;
}


print "\nRetrieving the full description for catalog_item_id {$catalog_item['catalog_item_id']}\n";

$args = array(
    socket_id => $socket_id,
    catalog_item_id => $catalog_item['catalog_item_id']
);

$view_item_response = $api->view_item($args);

$item = $view_item_response['item'];
if ($item['description'])
{
    print "\tFound it!\n";
}
else
{
    print "\tThe description could not be retrieved.\n";
}

print "\nPlacing an order for catalog_item_id {$catalog_item['catalog_item_id']}...\n";

$args = array(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    external_order_number => intval(time()),

    first_name => 'John',
    last_name => 'Doe',
    address_1 => '123 Test St.',
    address_2 => 'Apt. B',
    city => 'Cincinnati',
    state_province => 'OH',
    postal_code => '00000',
    country => 'US',
    email => 'johndoe123@example.com',
    phone_number => '123-555-6789',
    items => array(
        array(
            catalog_item_id => $item['catalog_item_id'],
            quantity => 1,
            currency => "USD",
            catalog_price => (float) $item['catalog_price']
        )
    )
);

$order_number = $api->order_place($args);

print "\tThe order was created with the order_number: $order_number\n";

print "\nRetrieving all order placed by this script...\n";

$args = array(
    external_user_id => 'johndoe123',
    per_page => 10,
    page => 1
);

$order_list_response = $api->order_list($args);

$pager = $order_list_response["pager"];
print "\tFound {$pager['result_count']} orders. Currently on page {$pager['page']} of {$pager['last_page']}.\n";

$orders = $order_list_response["orders"]["OrderSummary"];

$order_number_from_order_place;

foreach($orders as $order)
{
    $order_number_from_order_place = $order['order_number'];
    print "\tOrder {$order['order_number']} which was placed on {$order['date_placed']}\n";
}

if($order_number_from_order_place)
{
    print "\nRetrieving tracking information for order_number $order_number_from_order_place...\n";
    $args = array(
        order_number => $order_number_from_order_place
    );
    $order = $api->order_track($args);

    print "\tThis is an order for {$order['first_name']} {$order['last_name']}\n";

    print "\tItems:\n";
    foreach($order['items']['OrderItem'] as $order_item)
    {
        print "\t\t{$order_item['name']} (status: {$order_item['order_item_status']})\n";
    }

    print "\tFulfillments:\n";
    foreach($order['fulfillments']['Fulfillment'] as $fulfillment)
    {
        print "\t\tFound a fulfillment created on {$fulfillment['fulfillment_date']}\n";

        print "\t\t\tMetadata:\n";
        foreach($fulfillment['metadata']['Meta'] as $metadata)
        {
            print "\t\t\t\t{$metadata['key']}: {$metadata['value']} [{$metadata['uri']}]\n";
        }
        print "\t\t\tItems:\n";
        foreach($fulfillment['items']['FulfillmentItem'] as $fulfillment_item)
        {
            print "\t\t\t\t{$fulfillment_item['name']}\n";
        }
    }
}
else
{
    print "Cannot run tracking tests...a test order is not yet available in your account.\n";
    print "\tIf an order was just created, please wait a few minutes then re-run this script.\n";
}


# carts!
if($catalog_item)
{
    $cart;

    print "\nTesting cart methods...\n";

    try
    {
        $api->cart_empty( array(
            socket_id => $socket_id,
            external_user_id => 'johndoe123'
        ) );

        $api->cart_unlock( array(
            socket_id => $socket_id,
            external_user_id => 'johndoe123'
        ) );
    }
    catch (Exception $e)
    {
        echo 'Caught exception: ',  $e->getMessage(), "\n";
    }


    $api->cart_set_address( array(
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
    ) );

    $api->cart_set_item_quantity( array(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        catalog_item_id => $catalog_item['catalog_item_id'],
        quantity => 5
    ) );

    $api->cart_add_item( array(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        catalog_item_id => $catalog_item['catalog_item_id'],
        quantity => 3
    ) );

    $api->cart_remove_item( array(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        catalog_item_id => $catalog_item['catalog_item_id'],
        quantity => 2
    ) );

    $api->cart_validate( array(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        locked => 1
    ) );

    $cart = $api->cart_view( array(
        socket_id => $socket_id,
        external_user_id => 'johndoe123'
    ) );

    $cart_order_number = $api->cart_order_place( array(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        cart_version => $cart['cart_version']
    ) );

    print "\tCreated order via the cart with order_number: $cart_order_number\n";
}
else
{
    print "Cannot run cart tests...a test order is not yet available in your account.\n";
    print "\tIf an order was just created, please wait a few minutes then re-run this script.\n";
}

?>
