package CatalogAPI::SQLiteV3::Collection;

use strict;
use CatalogAPI::SQLiteV3;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'collections',
    init_db => CatalogAPI::SQLiteV3->new(),
    
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
            class       => 'CatalogAPI::SQLiteV3::Brand',
            key_columns => { brand_id => 'id' },
        },
        category => {
            class       => 'CatalogAPI::SQLiteV3::Category',
            key_columns => { category_id => 'id' },
        },
        catalog_item => {
            class       => 'CatalogAPI::SQLiteV3::CatalogItem',
            key_columns => { catalog_item_id => 'id' },
        },        
        tag => {
            class       => 'CatalogAPI::SQLiteV3::Tag',
            key_columns => { tag_id => 'id' },
        },
    ],

);

1;
