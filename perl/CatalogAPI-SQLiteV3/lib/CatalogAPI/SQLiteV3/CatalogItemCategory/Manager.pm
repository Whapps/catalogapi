package CatalogAPI::SQLiteV3::CatalogItemCategory::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::CatalogItemCategory;

sub object_class { 'CatalogAPI::SQLiteV3::CatalogItemCategory' }

__PACKAGE__->make_manager_methods('catalog_item_categories');

1;

