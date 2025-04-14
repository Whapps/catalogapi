package CatalogAPI::SQLite::CatalogItem::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::CatalogItem;

sub object_class { 'CatalogAPI::SQLite::CatalogItem' }

__PACKAGE__->make_manager_methods('catalog_items');

1;

