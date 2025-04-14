package CatalogAPI::SQLite::CatalogItemSupplierPrice::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLite::CatalogItemSupplierPrice;

sub object_class { 'CatalogAPI::SQLite::CatalogItemSupplierPrice' }

__PACKAGE__->make_manager_methods('catalog_item_supplier_prices');

1;

