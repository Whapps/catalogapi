package CatalogAPI::SQLiteV3::Brand::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::Brand;

sub object_class { 'CatalogAPI::SQLiteV3::Brand' }

__PACKAGE__->make_manager_methods('brands');

1;

