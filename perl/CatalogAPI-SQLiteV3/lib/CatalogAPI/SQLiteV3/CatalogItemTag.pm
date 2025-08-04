package CatalogAPI::SQLiteV3::CatalogItemTag;

use strict;
use CatalogAPI::SQLiteV3;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'catalog_item_tags',
    init_db => CatalogAPI::SQLiteV3->new(),

    columns => [
        catalog_item_id => { type => 'integer', not_null => 1 },
        tag_id          => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'catalog_item_id', 'tag_id' ],

    foreign_keys => [
        catalog_items => {
            class       => 'CatalogAPI::SQLiteV3::CatalogItem',
            key_columns => { catalog_item_id => 'id' },
        },

        tags => {
            class       => 'CatalogAPI::SQLiteV3::Tag',
            key_columns => { tag_id => 'id' },
        },
    ],
);

1;
