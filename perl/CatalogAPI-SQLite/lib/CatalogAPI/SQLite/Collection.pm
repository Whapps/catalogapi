package CatalogAPI::SQLite::Collection;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'collections',
    init_db => CatalogAPI::SQLite->new(),
    
    columns => [
        tag_id          => { type => 'integer' },
        brand_id        => { type => 'integer' },
        category_id     => { type => 'integer' },
        catalog_item_id => { type => 'integer' },
        name            => { type => 'varchar', length => 255, not_null => 1 },
        marketing_json  => { type => 'text' },
    ],

    primary_key_columns => [ 'tag_id', 'brand_id', 'category_id' ],

    foreign_keys => [
        brand => {
            class       => 'CatalogAPI::SQLite::Brand',
            key_columns => { brand_id => 'id' },
        },
        category => {
            class       => 'CatalogAPI::SQLite::Category',
            key_columns => { category_id => 'id' },
        },
        catalog_item => {
            class       => 'CatalogAPI::SQLite::CatalogItem',
            key_columns => { catalog_item_id => 'id' },
        },        
        tag => {
            class       => 'CatalogAPI::SQLite::Tag',
            key_columns => { tag_id => 'id' },
        },
    ],

);

1;
