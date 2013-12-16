<?php
require_once 'catalogapi.php';

// usage: php test.php -d testco -k 'mysecretkey'

$options = getopt("d:k:x");

$catalogapi = new CatalogAPI($options["d"], $options["k"], ($options["x"] ? "restx" : "rest"), FALSE);

$catalogs_ref = $catalogapi->list_available_catalogs();
if ($catalogs_ref == NULL || $catalogs_ref == "")
{
    print $catalogapi->error . "\n";
}
else
{
    if (!$options["x"])
    {
        print "DUMP: " . var_dump($catalogs_ref);
        
        // this is a BIT verbose ;)
        print "Account: " . $catalogs_ref["list_available_catalogs_response"]["list_available_catalogs_result"]["domain"]["account_name"] . "\n";
        
        $socket_id = $catalogs_ref["list_available_catalogs_response"]["list_available_catalogs_result"]["domain"]["sockets"]["Socket"][0]["socket_id"] . "\n";
        print "got socket_id: $socket_id\n";
        
        $breakdown = $catalogapi->catalog_breakdown($socket_id);
        print var_dump($breakdown);
        
        $search = $catalogapi->search_catalog($socket_id, array( search => "ipod" ));
        print var_dump($search);
    }
    else
    {
        print $catalogs_ref;
    }
}

?>