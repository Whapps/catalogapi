package CatalogAPI::SQLiteV3::ProductImage;

use strict;
use CatalogAPI::SQLiteV3;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'product_images',
    init_db => CatalogAPI::SQLiteV3->new(),

    columns => [
        id                    => { type => 'varchar', length   => 36, not_null => 1 },
        catalog_item_id       => { type => 'integer', not_null => 1 },
        alt                   => { type => 'varchar', length   => 255 },
        order                 => { type => 'integer', not_null => 1 },
        image_500_3_2         => { type => 'varchar', length   => 255 },
        image_300_3_2         => { type => 'varchar', length   => 255 },
        image_150_3_2         => { type => 'varchar', length   => 255 },
        image_75_3_2          => { type => 'varchar', length   => 255 },
        image_500_1_1         => { type => 'varchar', length   => 255 },
        image_300_1_1         => { type => 'varchar', length   => 255 },
        image_150_1_1         => { type => 'varchar', length   => 255 },
        image_75_1_1          => { type => 'varchar', length   => 255 }
    ],

    primary_key_columns => ['id'],

    foreign_keys => [
        catalog_item => {
            class       => 'CatalogAPI::SQLiteV3::CatalogItem',
            key_columns => { catalog_item_id => 'id' },
        },
    ],
);

1;
