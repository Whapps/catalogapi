#!/usr/bin/env perl
use strict;
use lib '../Whapps-CatalogAPI/lib';
use Whapps::CatalogAPI;

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

unless ($SECRET_KEY && $ENDPOINT)
{
    die 'You must first set the "catalogapi_key" and "catalogapi_endpoint" environment variables before running this script.';
}

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
    print "\t$socket->{socket_name} (socket_id: $socket->{socket_id})\n";
    $socket_id = $socket->{socket_id};
}

print "\nRetreiving categories for socket_id $socket_id...\n";
my $catalog_breakdown_response = $api->catalog_breakdown(
    socket_id => $socket_id,
    is_flat => 0 );

foreach my $category (@{ $catalog_breakdown_response->{categories}->{Category} })
{
    process_category($category, 1);
}

sub process_category
{
    my ($category, $depth) = @_;
    print "\t"x$depth . "$category->{name}\n";
    foreach my $child (@{ $category->{children}->{Category} })
    {
        process_category($child, ++$depth);
    }
}

print "\nSearching the catalog for the word \"card\"...\n";
my $search_catalog_response = $api->search_catalog(
    socket_id => $socket_id,
    search => 'card' );

my $catalog_item;
foreach my $item (@{ $search_catalog_response->{items}->{CatalogItem} })
{
    print "\tFound match: $item->{name}\n";
    $catalog_item = $item;
}

print "\nRetrieving the full description for catalog_item_id $catalog_item->{catalog_item_id}\n";
my $view_item_response = $api->view_item(
    socket_id => $socket_id,
    catalog_item_id => $catalog_item->{catalog_item_id} );

my $item = $view_item_response->{item};
if ($item->{description})
{
    print "\tFound it!\n";
}
else
{
    print "\tThe description could not be retrieved.\n";
}

print "\nPlacing an order for catalog_item_id $catalog_item->{catalog_item_id}...\n";
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
print "\tThe order was created with the order_number: $order_number\n";

print "\nRetrieving all order placed by this script...\n";
my $order_list_response = $api->order_list(
    external_user_id => 'johndoe123',
    per_page => 10,
    page => 1,
    );

my $pager = $order_list_response->{pager};
print "\tFound $pager->{result_count} orders. Currently on page $pager->{page} of $pager->{last_page}.\n";

my $orders = $order_list_response->{orders}->{OrderSummary};
my $order_number_from_order_place;
foreach my $order (@$orders)
{
    $order_number_from_order_place = $order->{order_number};
    print "\tOrder $order->{order_number} was placed on $order->{date_placed}\n";
}

## tracking
if ($order_number_from_order_place)
{
    print "\nRetrieving tracking information for order_number $order_number_from_order_place...\n";
    my $order = $api->order_track( order_number => $order_number_from_order_place );

    print "\tThis is an order for $order->{first_name} $order->{last_name}\n";
    print "\tItems:\n";
    foreach my $order_item (@{ $order->{items}->{OrderItem} })
    {
        print "\t\t$order_item->{name} (status: $order_item->{order_item_status})\n";
    }
    
    print "\tFulfillments:\n";
    foreach my $fulfillment (@{ $order->{fulfillments}->{Fulfillment} })
    {
        print "\t\tFound a fulfillment created on $fulfillment->{fulfillment_date}\n";
        print "\t\t\tMetadata:\n";
        foreach my $metadata (@{ $fulfillment->{metadata}->{Meta} })
        {
            print "\t\t\t\t$metadata->{key}: $metadata->{value}$metadata->{uri}\n";
        }
        print "\t\t\tItems:\n";
        foreach my $fulfillment_item (@{ $fulfillment->{items}->{FulfillmentItem} })
        {
            print "\t\t\t\t$fulfillment_item->{name}\n";
        }
    }
}
else
{
    print "Cannot run tracking tests...a test order is not yet available in your account.\n";
    print "\tIf an order was just created, please wait a few minutes then re-run this script.\n";
}

# carts!
if ($catalog_item)
{
    my $cart;
    
    print "\nTesting cart methods...\n";

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

    $api->cart_validate(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        locked => 1,
        );

    $cart = $api->cart_view(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        );

    my $cart_order_number = $api->cart_order_place(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        cart_version => $cart->{cart_version},
        );
    print "\tCreated order via the cart with order_number: $cart_order_number\n";
}
else
{
    print "Cannot run cart tests...a test order is not yet available in your account.\n";
    print "\tIf an order was just created, please wait a few minutes then re-run this script.\n";
}
    