package CatalogAPI::SQLite::Category::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::Category;

sub object_class { 'CatalogAPI::SQLite::Category' }

__PACKAGE__->make_manager_methods('categories');

1;

