package CatalogAPI::SQLite::Search::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::Search;

sub object_class { 'CatalogAPI::SQLite::Search' }

__PACKAGE__->make_manager_methods('Searchs');

1;

