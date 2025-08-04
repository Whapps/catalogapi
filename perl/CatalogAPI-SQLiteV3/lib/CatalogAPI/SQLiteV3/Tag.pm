package CatalogAPI::SQLiteV3::Tag;

use strict;
use CatalogAPI::SQLiteV3;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'tags',
    init_db => CatalogAPI::SQLiteV3->new(),
    
    columns => [
        id               => { type => 'integer', not_null => 1 },
        name             => { type => 'varchar', length   => 255, not_null => 1 },
        discount_percent => { type => 'scalar',  not_null => 1 },
        item_count       => { type => 'integer', default  => '0' },
    ],

    primary_key_columns => ['id'],

    relationships => [
        collections => {
            class      => 'CatalogAPI::SQLiteV3::Collection',
            column_map => { id => 'tag_id' },
            type       => 'one to many',
        },
        catalog_items => {
            map_class => 'CatalogAPI::SQLiteV3::CatalogItemTag',
            map_from  => 'tags',
            map_to    => 'catalog_items',
            type      => 'many to many',
        },
    ],
);

1;
