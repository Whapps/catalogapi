package CatalogAPI::SQLite::CatalogItemCategory;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'catalog_item_categories',
    init_db => CatalogAPI::SQLite->new(),
    
    columns => [
        catalog_item_id => { type => 'integer', not_null => 1 },
        category_id     => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'catalog_item_id', 'category_id' ],

    foreign_keys => [
        catalog_items => {
            class       => 'CatalogAPI::SQLite::CatalogItem',
            key_columns => { catalog_item_id => 'id' },
        },

        categories => {
            class       => 'CatalogAPI::SQLite::Category',
            key_columns => { category_id => 'id' },
        },
    ],       
);

1;

