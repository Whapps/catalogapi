package CatalogAPI::SQLite::Search;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'search',
    init_db => CatalogAPI::SQLite->new(),

    columns => [
        catalog_item_id => { type => 'integer' },
        name            => { type => 'varchar', length => 255, not_null => 1 },
        brand           => { type => 'varchar', length => 255, not_null => 1 },
        description     => { type => 'text' },
        extra           => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => ['catalog_item_id'],

    foreign_keys => [
        catalog_item => {
            class       => 'CatalogAPI::SQLite::CatalogItem',
            key_columns => { catalog_item_id => 'id' },
        },
    ],
);
