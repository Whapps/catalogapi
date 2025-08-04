package CatalogAPI::SQLiteV3::Search::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::Search;

sub object_class { 'CatalogAPI::SQLiteV3::Search' }

__PACKAGE__->make_manager_methods('Searchs');

1;

