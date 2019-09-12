<?php

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
