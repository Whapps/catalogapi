package CatalogAPI::SQLite::Catalog::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::Catalog;

sub object_class { 'CatalogAPI::SQLite::Catalog' }

__PACKAGE__->make_manager_methods('catalogs');

1;

