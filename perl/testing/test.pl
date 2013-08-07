#!/usr/bin/env perl
use strict;
use lib '../Whapps-CatalogAPI/lib';
use Whapps::CatalogAPI;
use Data::Dumper;

# this script will test every method
# it will create actual test orders in the system
#
# cd into testing/
# set you key and endpoint in the environment:
#
#   $ export catalogapi_key='yourkey'
#   $ export catalogapi_endpoint='yourdomain.dev.catalogapi.com'
#
# then run this script

my $SECRET_KEY = $ENV{catalogapi_key};
my $ENDPOINT = $ENV{catalogapi_endpoint}; # yourdomain.dev.catalogapi.com

if ($ENDPOINT =~ /\.prod\./i)
{
    die "do not use your prod domain with this testing script";
}

my $api = Whapps::CatalogAPI->new(
    secret_key => $SECRET_KEY,
    endpoint => $ENDPOINT );
    
my $list_available_catalogs_response = $api->list_available_catalogs();

my $domain = $list_available_catalogs_response->{domain};
print "The following sockets are available for the $domain->{account_name} account.\n";

my $socket_id;
foreach my $socket (@{ $domain->{sockets}->{Socket} })
{
    print "got socket: $socket->{socket_name}\n";
    $socket_id = $socket->{socket_id};
}

my $catalog_breakdown_response = $api->catalog_breakdown(
    socket_id => $socket_id,
    is_flat => 0 );

foreach my $category (@{ $catalog_breakdown_response->{categories}->{Category} })
{
    process_category($category, 0);
}

sub process_category
{
    my ($category, $depth) = @_;
    print "\t"x$depth . "found category: $category->{name}\n";
    foreach my $child (@{ $category->{children}->{Category} })
    {
        process_category($child, ++$depth);
    }
}

my $search_catalog_response = $api->search_catalog(
    socket_id => $socket_id,
    search => 'card' );

my $catalog_item;
foreach my $item (@{ $search_catalog_response->{items}->{CatalogItem} })
{
    print "found item: $item->{name}\n";
    $catalog_item = $item;
}

my $view_item_response = $api->view_item(
    socket_id => $socket_id,
    catalog_item_id => $catalog_item->{catalog_item_id} );

my $item = $view_item_response->{item};
print "viewing item: $item->{name}\n$item->{description}\n";

my $order_number = $api->order_place(
    
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    external_order_number => int(time()),
    
    first_name => 'John',
    last_name => 'Doe',
    address_1 => '123 Test St.',
    address_2 => 'Apt. B',
    city => 'Cincinnati',
    state_province => 'OH',
    postal_code => '00000',
    country => 'US',
    email => 'johndoe123@example.com',
    phone_number => '123-555-6789',
    
    items => [{
        "catalog_item_id" => $item->{catalog_item_id},
        "quantity" => 1,
        "currency" => "USD",
        "catalog_price" => $item->{catalog_price},
        }]
);
print "the order was created with the order_number: $order_number\n";

my $order_list_response = $api->order_list(
    external_user_id => 'johndoe123',
    per_page => 10,
    page => 1,
    );

my $pager = $order_list_response->{pager};
print "Found $pager->{result_count} orders. Currently on page $pager->{page} of $pager->{last_page}.\n";

my $orders = $order_list_response->{orders}->{OrderSummary};
my $order_number_from_order_place;
foreach my $order (@$orders)
{
    $order_number_from_order_place = $order->{order_number};
    print "found order $order->{order_number} which was placed on $order->{date_placed}\n";
}

## tracking

my $order = $api->order_track( order_number => $order_number_from_order_place );

print "this is an order for $order->{first_name} $order->{last_name}\n";

foreach my $order_item (@{ $order->{items}->{OrderItem} })
{
    print "found order item: $order_item->{name} ($order_item->{order_item_status})\n";
}

foreach my $fulfillment (@{ $order->{fulfillments}->{Fulfillment} })
{
    print "found fulfillment created on $fulfillment->{fulfillment_date}\n";
    foreach my $metadata (@{ $fulfillment->{metadata}->{Meta} })
    {
        print "\t$metadata->{key}: $metadata->{value} [$metadata->{uri}]\n";
    }
    foreach my $fulfillment_item (@{ $fulfillment->{items}->{FulfillmentItem} })
    {
        print "\tfulfillment includes the item: $fulfillment_item->{name}\n";
    }
}

# carts!

my $cart;

$api->cart_unlock(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    );

$api->cart_empty(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    catalog_item_id => $catalog_item->{catalog_item_id},
    quantity => 2
    );

$cart = $api->cart_view(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    );
print Dumper($cart);

$api->cart_set_address(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    
    first_name => 'John',
    last_name => 'Doe',
    address_1 => '123 Test St.',
    address_2 => 'Apt. B',
    city => 'Cincinnati',
    state_province => 'OH',
    postal_code => '00000',
    country => 'US',
    email => 'johndoe123@example.com',
    phone_number => '123-555-6789',
    );

$api->cart_set_item_quantity(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    catalog_item_id => $catalog_item->{catalog_item_id},
    quantity => 5
    );

$api->cart_add_item(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    catalog_item_id => $catalog_item->{catalog_item_id},
    quantity => 3
    );
    
$api->cart_remove_item(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    catalog_item_id => $catalog_item->{catalog_item_id},
    quantity => 2
    );

$cart = $api->cart_view(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    );
print Dumper($cart);

$api->cart_validate(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    locked => 1,
    );

$cart = $api->cart_view(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    );
print Dumper($cart);

my $cart_order_number = $api->cart_order_place(
    socket_id => $socket_id,
    external_user_id => 'johndoe123',
    cart_version => $cart->{cart_version},
    );
print "created order: $cart_order_number\n";
    