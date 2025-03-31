package CatalogAPI::SQLite::CatalogItemTag;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'catalog_item_tags',
    init_db => CatalogAPI::SQLite->new(),

    columns => [
        catalog_item_id => { type => 'integer', not_null => 1 },
        tag_id          => { type => 'integer', not_null => 1 },
    ],

    primary_key_columns => [ 'catalog_item_id', 'tag_id' ],

    foreign_keys => [
        catalog_items => {
            class       => 'CatalogAPI::SQLite::CatalogItem',
            key_columns => { catalog_item_id => 'id' },
        },

        tags => {
            class       => 'CatalogAPI::SQLite::Tag',
            key_columns => { tag_id => 'id' },
        },
    ],
);

1;
