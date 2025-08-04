package CatalogAPI::SQLiteV3::Brand;

use strict;
use CatalogAPI::SQLiteV3;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'brands',
    init_db => CatalogAPI::SQLiteV3->new(),
    
    columns => [
        id         => { type => 'integer', not_null => 1 },
        name       => { type => 'varchar', length   => 255, not_null => 1 },
        item_count => { type => 'integer' },
    ],

    primary_key_columns => ['id'],

    relationships => [
        catalog_items => {
            class      => 'CatalogAPI::SQLiteV3::CatalogItem',
            column_map => { id => 'brand_id' },
            type       => 'one to many',
        },
        collections => {
            class      => 'CatalogAPI::SQLiteV3::Collection',
            column_map => { id => 'brand_id' },
            type       => 'one to many',
        },
    ],
);

1;
