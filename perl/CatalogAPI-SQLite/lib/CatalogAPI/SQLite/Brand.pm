package CatalogAPI::SQLite::Brand;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'brands',
    init_db => CatalogAPI::SQLite->new(),
    
    columns => [
        id         => { type => 'integer', not_null => 1 },
        name       => { type => 'varchar', length   => 255, not_null => 1 },
        item_count => { type => 'integer' },
    ],

    primary_key_columns => ['id'],

    relationships => [
        catalog_items => {
            class      => 'CatalogAPI::SQLite::CatalogItem',
            column_map => { id => 'brand_id' },
            type       => 'one to many',
        },
        collections => {
            class      => 'CatalogAPI::SQLite::Collection',
            column_map => { id => 'brand_id' },
            type       => 'one to many',
        },
    ],
);

1;
