package CatalogAPI::SQLite::TagCategory::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::TagCategory;

sub object_class { 'CatalogAPI::SQLite::TagCategory' }

__PACKAGE__->make_manager_methods('tag_categories');

1;

