package CatalogAPI::SQLite::CatalogItemSupplierPrice;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'catalog_item_supplier_prices',
    init_db => CatalogAPI::SQLite->new(),

    columns => [
        catalog_item_id       => { type => 'integer', not_null => 1 },
        supplier_id           => { type => 'integer', not_null => 1 },
        region_id             => { type => 'integer', not_null => 1 },
        currency              => { type => 'varchar', length   => 3, not_null => 1 },
        currency_id           => { type => 'integer', not_null => 1 },
        base_price            => { type => 'scalar',  not_null => 1 },
        retail_price          => { type => 'scalar',  not_null => 1 },
        shipping_estimate     => { type => 'scalar',  not_null => 1 },
        supplier_reference_id => { type => 'varchar', length   => 255, not_null => 1 },
        item_type_id          => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => ['catalog_item_id'],

    foreign_keys => [
        catalog_item => {
            class       => 'CatalogAPI::SQLite::CatalogItem',
            key_columns => { catalog_item_id => 'id' },
        },
    ],
);

1;
