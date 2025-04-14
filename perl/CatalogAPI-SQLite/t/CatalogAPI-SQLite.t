# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl CatalogAPI-SQLite.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 12;
BEGIN { 
    use_ok('CatalogAPI::SQLite'); 
    use_ok('CatalogAPI::SQLite::Brand::Manager');
    use_ok('CatalogAPI::SQLite::Catalog::Manager');
    use_ok('CatalogAPI::SQLite::CatalogItem::Manager');
    use_ok('CatalogAPI::SQLite::CatalogItemCategory::Manager');
    use_ok('CatalogAPI::SQLite::CatalogItemSupplierPrice::Manager');
    use_ok('CatalogAPI::SQLite::CatalogItemTag::Manager');
    use_ok('CatalogAPI::SQLite::Category::Manager');
    use_ok('CatalogAPI::SQLite::Collection::Manager');
    use_ok('CatalogAPI::SQLite::Search::Manager');
    use_ok('CatalogAPI::SQLite::Tag::Manager');
    use_ok('CatalogAPI::SQLite::TagCategory::Manager');
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

