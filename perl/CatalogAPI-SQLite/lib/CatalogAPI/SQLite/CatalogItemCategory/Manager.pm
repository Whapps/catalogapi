package CatalogAPI::SQLite::CatalogItemCategory::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::CatalogItemCategory;

sub object_class { 'CatalogAPI::SQLite::CatalogItemCategory' }

__PACKAGE__->make_manager_methods('catalog_item_categories');

1;

