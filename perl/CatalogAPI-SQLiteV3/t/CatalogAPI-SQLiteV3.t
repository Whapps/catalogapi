# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl CatalogAPI-SQLiteV3.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 12;
BEGIN { 
    use_ok('CatalogAPI::SQLiteV3'); 
    use_ok('CatalogAPI::SQLiteV3::Brand::Manager');
    use_ok('CatalogAPI::SQLiteV3::Catalog::Manager');
    use_ok('CatalogAPI::SQLiteV3::CatalogItem::Manager');
    use_ok('CatalogAPI::SQLiteV3::CatalogItemCategory::Manager');
    use_ok('CatalogAPI::SQLiteV3::ProductImage::Manager');
    use_ok('CatalogAPI::SQLiteV3::CatalogItemTag::Manager');
    use_ok('CatalogAPI::SQLiteV3::Category::Manager');
    use_ok('CatalogAPI::SQLiteV3::Collection::Manager');
    use_ok('CatalogAPI::SQLiteV3::Search::Manager');
    use_ok('CatalogAPI::SQLiteV3::Tag::Manager');
    use_ok('CatalogAPI::SQLiteV3::TagCategory::Manager');
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

