package CatalogAPI::SQLiteV3::Tag::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::Tag;

sub object_class { 'CatalogAPI::SQLiteV3::Tag' }

__PACKAGE__->make_manager_methods('tags');

1;

