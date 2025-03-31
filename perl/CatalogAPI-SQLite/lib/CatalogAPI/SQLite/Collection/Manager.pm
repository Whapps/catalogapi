package CatalogAPI::SQLite::Collection::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::Collection;

sub object_class { 'CatalogAPI::SQLite::Collection' }

__PACKAGE__->make_manager_methods('collections');

1;

