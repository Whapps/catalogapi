package CatalogAPI::SQLite::TagCategory;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table => 'tag_categories',
    init_db => CatalogAPI::SQLite->new(),
    
    columns => [
        id                 => { type => 'integer', not_null => 1 },
        tag_id             => { type => 'integer', not_null => 1 },
        name               => { type => 'varchar', length   => 255, not_null => 1 },
        parent_category_id => { type => 'integer' },
        left_id            => { type => 'integer' },
        right_id           => { type => 'integer' },
        item_count         => { type => 'integer' },
    ],

    primary_key_columns => [ 'id', 'tag_id' ],

    relationships => [
        tag => {
            class      => 'CatalogAPI::SQLite::Tag',
            column_map => { tag_id => 'id' },
            type       => 'one to many',
        },
    ],
);

1;
