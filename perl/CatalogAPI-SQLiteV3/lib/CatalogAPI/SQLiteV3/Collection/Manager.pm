package CatalogAPI::SQLiteV3::Collection::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::Collection;

sub object_class { 'CatalogAPI::SQLiteV3::Collection' }

__PACKAGE__->make_manager_methods('collections');

1;

