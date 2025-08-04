package CatalogAPI::SQLiteV3::CatalogItem::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::CatalogItem;

sub object_class { 'CatalogAPI::SQLiteV3::CatalogItem' }

__PACKAGE__->make_manager_methods('catalog_items');

1;

