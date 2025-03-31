package CatalogAPI::SQLite::CatalogItemTag::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::CatalogItemTag;

sub object_class { 'CatalogAPI::SQLite::CatalogItemTag' }

__PACKAGE__->make_manager_methods('catalog_item_tags');

1;

