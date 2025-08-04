package CatalogAPI::SQLiteV3::Category::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::Category;

sub object_class { 'CatalogAPI::SQLiteV3::Category' }

__PACKAGE__->make_manager_methods('categories');

1;

