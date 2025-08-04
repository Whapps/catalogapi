package CatalogAPI::SQLiteV3::Catalog::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::Catalog;

sub object_class { 'CatalogAPI::SQLiteV3::Catalog' }

__PACKAGE__->make_manager_methods('catalogs');

1;

