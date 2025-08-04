package CatalogAPI::SQLiteV3::TagCategory::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::TagCategory;

sub object_class { 'CatalogAPI::SQLiteV3::TagCategory' }

__PACKAGE__->make_manager_methods('tag_categories');

1;

