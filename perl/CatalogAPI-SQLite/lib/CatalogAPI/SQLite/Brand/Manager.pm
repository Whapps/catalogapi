package CatalogAPI::SQLite::Brand::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::Brand;

sub object_class { 'CatalogAPI::SQLite::Brand' }

__PACKAGE__->make_manager_methods('brands');

1;

