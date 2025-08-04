package CatalogAPI::SQLiteV3::CatalogItemTag::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::CatalogItemTag;

sub object_class { 'CatalogAPI::SQLiteV3::CatalogItemTag' }

__PACKAGE__->make_manager_methods('catalog_item_tags');

1;

