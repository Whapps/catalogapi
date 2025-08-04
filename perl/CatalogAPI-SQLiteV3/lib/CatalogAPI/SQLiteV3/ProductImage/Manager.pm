package CatalogAPI::SQLiteV3::ProductImage::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CatalogAPI::SQLiteV3::ProductImage;

sub object_class { 'CatalogAPI::SQLiteV3::ProductImage' }

__PACKAGE__->make_manager_methods('product_images');

1;

