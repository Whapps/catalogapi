package CatalogAPI::SQLiteV3::CatalogItem;

use strict;
use CatalogAPI::SQLiteV3;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'catalog_items',
    init_db => CatalogAPI::SQLiteV3->new(),
    
    columns => [
        id                         => { type => 'integer', not_null => 1 },
        price                      => { type => 'scalar',  default  => '\'\'', not_null => 1 },
        points                     => { type => 'integer', not_null => 1 },
        original_price             => { type => 'scalar',  not_null => 1 },
        original_points            => { type => 'integer', not_null => 1 },
        shipping                   => { type => 'scalar',  not_null => 1 },
        retail_price               => { type => 'scalar',  not_null => 1 },
        rank                       => { type => 'integer', not_null => 1 },
        name                       => { type => 'varchar', length   => 255, not_null => 1 },
        supplier_reference_id      => { type => 'varchar', length   => 255, not_null => 1 },
        availability               => { type => 'varchar', length   => 255, not_null => 1 },
        description                => { type => 'text',    not_null => 1 },
        model                      => { type => 'varchar', length   => 255, not_null => 1 },
        brand_id                   => { type => 'integer', not_null => 1 },
        image_500                  => { type => 'varchar', length   => 255, not_null => 1 },
        image_300                  => { type => 'varchar', length   => 255, not_null => 1 },
        image_150                  => { type => 'varchar', length   => 255, not_null => 1 },
        image_75                   => { type => 'varchar', length   => 255, not_null => 1 },
        product_id                 => { type => 'varchar', length   => 255, not_null => 1 },
        is_primary                 => { type => 'integer', default  => '0', not_null => 1 },
        required_fields            => { type => 'text' },
        product_options            => { type => 'text' },
        face_value                 => { type => 'scalar' },
        face_currency              => { type => 'varchar', length   => 3, not_null => 1 },
        is_limited_stock           => { type => 'integer', default  => '0', not_null => 1 },
        is_taxable                 => { type => 'integer', default  => '0', not_null => 1 },
        fulfillment_type           => { type => 'varchar', length   => 50 },
        supplier_id                => { type => 'integer', not_null => 1 },
        supplier_currency          => { type => 'varchar', length   => 3, not_null => 1 },
        supplier_retail_price      => { type => 'scalar', not_null => 1 },
        supplier_shipping_estimate => { type => 'scalar', not_null => 1 },
        item_type_id               => { type => 'integer', not_null => 1 },
        supplier_reference_id      => { type => 'varchar', length   => 255, not_null => 1 },
    ],

    primary_key_columns => ['id'],

    foreign_keys => [
        brand => {
            class       => 'CatalogAPI::SQLiteV3::Brand',
            key_columns => { brand_id => 'id' },
        },
        search => {
            class       => 'CatalogAPI::SQLiteV3::Search',
            key_columns => { id => 'catalog_item_id' },
        },
    ],

    relationships => [
        product_images => {
            class      => 'CatalogAPI::SQLiteV3::ProductImage',
            column_map => { id => 'catalog_item_id' },
            type       => 'one to many',
        },
        categories => {
            map_class => 'CatalogAPI::SQLiteV3::CatalogItemCategory',
            map_from  => 'catalog_items',
            map_to    => 'categories',
            type      => 'many to many',
        },
        tags => {
            map_class => 'CatalogAPI::SQLiteV3::CatalogItemTag',
            map_from  => 'catalog_items',
            map_to    => 'tags',
            type      => 'many to many',
        },
    ],
);

1;
