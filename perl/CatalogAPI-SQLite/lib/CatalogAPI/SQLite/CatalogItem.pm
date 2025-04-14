package CatalogAPI::SQLite::CatalogItem;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'catalog_items',
    init_db => CatalogAPI::SQLite->new(),
    
    columns => [
        id              => { type => 'integer', not_null => 1 },
        price           => { type => 'scalar',  default  => '\'\'', not_null => 1 },
        points          => { type => 'integer', not_null => 1 },
        original_price  => { type => 'scalar',  not_null => 1 },
        original_points => { type => 'integer', not_null => 1 },
        shipping        => { type => 'scalar',  not_null => 1 },
        retail_price    => { type => 'scalar',  not_null => 1 },
        rank            => { type => 'integer', not_null => 1 },
        name            => { type => 'varchar', length   => 255, not_null => 1 },
        description     => { type => 'text',    not_null => 1 },
        model           => { type => 'varchar', length   => 255, not_null => 1 },
        brand_id        => { type => 'integer', not_null => 1 },
        image_500       => { type => 'varchar', length   => 255, not_null => 1 },
        image_300       => { type => 'varchar', length   => 255, not_null => 1 },
        image_150       => { type => 'varchar', length   => 255, not_null => 1 },
        image_75        => { type => 'varchar', length   => 255, not_null => 1 },
        has_options     => { type => 'integer', default  => '0', not_null => 1 },
        options         => { type => 'text' },
    ],

    primary_key_columns => ['id'],

    foreign_keys => [
        brand => {
            class       => 'CatalogAPI::SQLite::Brand',
            key_columns => { brand_id => 'id' },
        },
        search => {
            class       => 'CatalogAPI::SQLite::Search',
            key_columns => { id => 'catalog_item_id' },
        },
    ],

    relationships => [
        supplier_prices => {
            class      => 'CatalogAPI::SQLite::CatalogItemSupplierPrice',
            column_map => { id => 'catalog_item_id' },
            type       => 'one to many',
        },
        categories => {
            map_class => 'CatalogAPI::SQLite::CatalogItemCategory',
            map_from  => 'catalog_items',
            map_to    => 'categories',
            type      => 'many to many',
        },
        tags => {
            map_class => 'CatalogAPI::SQLite::CatalogItemTag',
            map_from  => 'catalog_items',
            map_to    => 'tags',
            type      => 'many to many',
        },
    ],
);

1;
