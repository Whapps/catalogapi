package CatalogAPI::SQLiteV3::Category;

use strict;
use CatalogAPI::SQLiteV3;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'categories',
    init_db => CatalogAPI::SQLiteV3->new(),
    
    columns => [
        id                 => { type => 'integer', not_null => 1 },
        name               => { type => 'varchar', length   => 255, not_null => 1 },
        parent_category_id => { type => 'integer' },
        left_id            => { type => 'integer' },
        right_id           => { type => 'integer' },
        item_count         => { type => 'integer' },
    ],

    primary_key_columns => ['id'],

    relationships => [
        collections => {
            class      => 'CatalogAPI::SQLiteV3::Collection',
            column_map => { id => 'category_id' },
            type       => 'one to many',
        },
        catalog_items => {
            map_class => 'CatalogAPI::SQLiteV3::CatalogItemCategory',
            map_from  => 'categories',
            map_to    => 'catalog_items',
            type      => 'many to many',
        },
    ],
);

1;
