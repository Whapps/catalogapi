package CatalogAPI::SQLite::Catalog;

use strict;
use CatalogAPI::SQLite;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'catalogs',
    init_db => CatalogAPI::SQLite->new(),

    columns => [
        id                      => { type => 'integer', not_null => 1 },
        name                    => { type => 'varchar', length => 255, not_null => 1 },
        point_to_currency_ratio => { type => 'scalar', not_null => 1 },
        price_currency          => { type => 'varchar', length => 3, not_null => 1 },
        point_currency          => { type => 'varchar', length => 3, not_null => 1 },
        language                => { type => 'varchar', length => 20, not_null => 1 },
        language_id             => { type => 'integer', not_null => 1 },
        region                  => { type => 'varchar', length => 20, not_null => 1 },
        region_id               => { type => 'integer', not_null => 1 },
        indexed_at              => { type => 'datetime', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

