package CatalogAPI::SQLite::Tag::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::Tag;

sub object_class { 'CatalogAPI::SQLite::Tag' }

__PACKAGE__->make_manager_methods('tags');

1;

