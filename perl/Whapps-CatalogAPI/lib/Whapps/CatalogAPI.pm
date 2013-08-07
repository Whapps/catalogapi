package Whapps::CatalogAPI;
use 5.014;
use strict;

our $VERSION = 1.0;
our $API_VERSION = 'v1';

use LWP::UserAgent qw();
use URI::Escape qw(uri_escape_utf8);
use JSON qw(to_json from_json);
use Data::UUID qw();
use Digest::HMAC_SHA1 qw(hmac_sha1);
use MIME::Base64 qw(encode_base64);
use DateTime;
use Carp;

=head1 DESCRIPTION

Whapps::CatalogAPI is a perl interface to the catalogapi.com API.

All of the methods return a perl data structure that looks exactly like the
JSON response examples at catalogapi.com except that the response data structures
do not include the {METHODNAME_response}->{METHODNAME_response} hash keys.
This makes it easier to work with the responses.

=head1 CATALOG BROWSE METHODS

=head2 new

You must pass your secret key and the endpoint uri
when creating a new Whapps::CatalogAPI instance.

    my $api = Whapps::CatalogAPI->new(
        secret_key => 'yoursecretkey',
        endpoint => 'your_domain.dev.catalogapi.com',
        # keep_alive is on by default.
        # Set to 0 if you encounter any issues with keep_alive.
        keep_alive => 1,
        );

=cut

my $AGENT;

sub new
{
    my ($class, %args) = @_;
    my $self = bless \%args, $class;
    
    # will only be used to setup the $AGENT on the first instance creation
    my $keep_alive = 2;
    if (defined($args{keep_alive}) && !$args{keep_alive})
    {
        $keep_alive = 0;
    }
    
    confess "your secret_key is required"
        unless $self->{secret_key};
    $self->{secret_key} =~ s/\s//g;
    
    confess "your endpoint is required"
        unless $self->{endpoint};
    $self->{endpoint} =~ s/^https?:\/\///;
    $self->{endpoint} =~ s/\/.*$//;
    
    unless ($AGENT)
    {
        $AGENT = LWP::UserAgent->new( keep_alive => $keep_alive );
        $AGENT->agent("Whapps::CatalogAPI $VERSION");
        $AGENT->timeout(30);
    }
    
    warn Data::Dumper::Dumper($self);
    
    return $self;
}

=head2 list_available_catalogs

    my $list_available_catalogs_response = $api->list_available_catalogs();
    
    my $domain = $list_available_catalogs_response->{domain};
    print "The following sockets are available for the $domain->{account_name} account.";
    
    foreach my $socket (@{ $domain->{sockets}->{Socket} })
    {
        print "got socket: $socket->{socket_name}\n";
    }

=cut
sub list_available_catalogs
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'list_available_catalogs' );
    my $ref = $response->{list_available_catalogs_response}->{list_available_catalogs_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 catalog_breakdown

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
    
=cut
sub catalog_breakdown
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'catalog_breakdown', %args );
    my $ref = $response->{catalog_breakdown_response}->{catalog_breakdown_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 search_catalog

Check the catalogapi.com documentation for a full list of search parameters.

    my $search_catalog_response = $api->search_catalog(
        socket_id => $socket_id,
        search => 'ipod' );
    
    foreach my $item (@{ $search_catalog_response->{items}->{CatalogItem} })
    {
        print "found item: $item->{name}\n";
    }

=cut
sub search_catalog
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'search_catalog', %args );
    my $ref = $response->{search_catalog_response}->{search_catalog_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 view_item

    my $view_item_response = $api->view_item(
        socket_id => $socket_id,
        catalog_item_id => $catalog_item_id );

    my $item = $view_item_response->{item};
    print "found item: $item->{name}\n$item->{description}\n";

=cut
sub view_item
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'view_item', %args );
    my $ref = $response->{view_item_response}->{view_item_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head1 CART METHODS

Carts provide a way to build an order through a REST interface.
You can add and remove items, set a shipping address, and place an order. These methods are explained below.

=head2 cart_add_item

Adds items to the cart.

    my $cart_add_item_response = $api->cart_add_item(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        catalog_item_id => $catalog_item_id,
        option_id => 123, # This is required for items that have options.
        quantity => 1 );

    print "$cart_add_item_response->{description}\n";

=cut
sub cart_add_item
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_add_item', %args );
    my $ref = $response->{cart_add_item_response}->{cart_add_item_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 cart_remove_item

Removes items from the cart.

    my $cart_remove_item_response = $api->cart_remove_item(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        catalog_item_id => $catalog_item_id,
        option_id => 123, # This is required for items that have options.
        );

    print "$cart_remove_item_response->{description}\n";

=cut
sub cart_remove_item
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_remove_item', %args );
    my $ref = $response->{cart_remove_item_response}->{cart_remove_item_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 cart_set_item_quantity

Adds items to the cart. The quantity passed to this call overrides the quantity of a duplicate item.

    my $cart_set_item_quantity_response = $api->cart_set_item_quantity(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        catalog_item_id => $catalog_item_id,
        option_id => 123, # This is required for items that have options.
        quantity => 2 );

    print "$cart_set_item_quantity_response->{description}\n";

=cut
sub cart_set_item_quantity
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_set_item_quantity', %args );
    my $ref = $response->{cart_set_item_quantity_response}->{cart_set_item_quantity_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 cart_empty

Removes all items in the cart.

    my $cart_empty_response = $api->cart_empty(
        socket_id => $socket_id,
        external_user_id => 'johndoe123' );

    print "$cart_empty_response->{description}\n";

=cut
sub cart_empty
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_empty', %args );
    my $ref = $response->{cart_empty_response}->{cart_empty_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 cart_set_address

Adds a shipping address to the cart.

    my $cart_set_address_response = $api->cart_set_address(
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

    print "$cart_set_address_response->{description}\n";

=cut
sub cart_set_address
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_set_address', %args );
    my $ref = $response->{cart_set_address_response}->{cart_set_address_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 cart_validate

Validates the address and items in the cart.
You should call this method just before placing an order to make sure that the order will not be rejected.

This method works a bit differently than the others.
It will return undef if the cart is valid,
otherwise it returns the error message string.

    my $error = $api->cart_validate(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        locked => 0 );

    if ($error)
    {
        warn "the cart is invalid: $error";
    }
    else
    {
        print "the cart is valid\n";
    }

=cut
sub cart_validate
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_validate', die_on_fault => 0, %args );
    if ($response->{Fault})
    {
        if ($response->{Fault}->{faultcode} eq 'Client.APIError')
        {
            return $response->{Fault}->{faultstring};
        }
        else
        {
            confess $response->{Fault}->{faultcode} . ': ' . $response->{Fault}->{faultstring};
        }
    }
    else
    {
        my $ref = $response->{cart_validate_response}->{cart_validate_result};
        $self->_validate_response($ref->{credentials});
        return;
    }
}

=head2 cart_unlock

Unlocks a cart that has been locked via the cart_validate method.

    my $cart_unlock_response = $api->cart_unlock(
        socket_id => $socket_id,
        external_user_id => 'johndoe123' );

    print "$cart_unlock_response->{description}\n";

=cut
sub cart_unlock
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_unlock', %args );
    my $ref = $response->{cart_unlock_response}->{cart_unlock_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

=head2 cart_view

Returns the current address and items in the cart.

This method can also be used to validate the cart.
While you can use the cart_validate method for this purpose,
cart_validate will simply return a single error message if the cart is invalid.
You can use the results from the cart_view method to find all of
the problems with a cart in order to display helpful feedback to the user.

In order for a cart to be valid, it must have:

* An address
* At least one item
* All items must be available (as specified through the is_available field on each item)
* All of the item's cart_price values must be less than or equal to the catalog_price values

    my $cart_view_response = $api->cart_view(
        socket_id => $socket_id,
        external_user_id => 'johndoe123' );
    
    if ( ! $cart_view_response->{first_name})
    {
        warn "The cart must have an address to place an order.";
    }
    else
    {
        print "Viewing cart for $cart_view_response->{first_name} $cart_view_response->{last_name}\n";
    }
    
    print "cart version: $cart_view_response->{cart_version}" . "\n";
    print "cart is locked?:" . ($cart_view_response->{locked} ? 'yes' : 'no') . "\n";
    
    # note that this code will only show a single error
    # when there are multiple quantities of the same item
    my %errors;
    my $has_item = 0;
    foreach my $cart_item (@{ $cart_view_response->{items}->{CartItem} })
    {
        $has_item = 1;
        unless ($cart_item->{is_available})
        {
            $errors{$cart_item->{name}} = "item is no longer available";
        }
        if ($cart_item->{catalog_price} > $cart_item->{cart_price})
        {
            $errors{$cart_item->{name}} = "the item has gone up in price, please remove then re-add the item";
        }
    }
    unless ($has_item)
    {
        warn "The must contain at least one item to place an order.";
    }
    if (%errors)
    {
        foreach my $item_name (keys %errors)
        {
            warn "There is a problem with the item: $item_name - $errors{$item_name}";
        }
    }

As a convenience, all of the cart errors will be in $cart_view_response->{errors}.
    
    if (@{ $cart_view_response->{errors} })
    {
        print "The cart contains errors.\n";
        
        foreach my $error (@{ $cart_view_response->{errors} })
        {
            print "$error->{error}\n";
            
            # you could also automatically remove invalid items here...
            if ($error->{catalog_item_id})
            {
                $api->cart_remove_item(
                    socket_id => $socket_id,
                    external_user_id => 'johndoe123',
                    catalog_item_id => $error->{catalog_item_id},
                    option_id => $error->{option_id},
                    );
            }
        }
    }
    else
    {
        print "The cart is valid.\n";
    }
    

=cut
sub cart_view
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_view', %args );
    my $ref = $response->{cart_view_response}->{cart_view_result};
    $self->_validate_response($ref->{credentials});
    
    my @errors;
    if ( ! $ref->{first_name})
    {
        push(@errors, { error => 'The cart must have an address to place an order.' });
    }
    
    my $has_item = 0;
    foreach my $cart_item (@{ $ref->{items}->{CartItem} })
    {
        $has_item = 1;
        unless ($cart_item->{is_available})
        {
            push(@errors, {
                error => 'Item is no longer available: ' . $cart_item->{name},
                catalog_item_id => $cart_item->{catalog_item_id},
                option_id => $cart_item->{option_id},
                });
        }
        if ($cart_item->{catalog_price} > $cart_item->{cart_price})
        {
            push(@errors, {
                error => 'The item has gone up in price since it was added to the cart, please remove then re-add the item: ' . $cart_item->{name},
                catalog_item_id => $cart_item->{catalog_item_id},
                option_id => $cart_item->{option_id},
                });
        }
    }
    
    unless ($has_item)
    {
        push(@errors, 'The cart must contain at least one item to place an order.');
    }
    
    $ref->{errors} = \@errors;
    
    return $ref;
}

=head2 cart_order_place

This method places as order using the address and items in the cart.
Once the order is placed, the cart is deleted.

It returns the order_number on success or dies on failure.

    my $order_number = $api->cart_order_place(
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        cart_version => $cart_version, # optional - this is the cart_version from the cart_view method
        );

    print "the order was created with the order_number: $order_number\n";

=cut
sub cart_order_place
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'cart_order_place', %args );
    my $ref = $response->{cart_order_place_response}->{cart_order_place_result};
    $self->_validate_response($ref->{credentials});
    return $ref->{order_number};
}

=head1 ORDER METHODS

=head2 order_place

This creates an order in the system without using a cart.

It returns the order_number on success or dies on failure.

    my $order_number = $api->order_place(
        
        socket_id => $socket_id,
        external_user_id => 'johndoe123',
        external_order_number => $unique_order_number_from_your_system,
        
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
        
        items => [
            {
                catalog_item_id => 1,
                quantity => 1,
                currency => "USD",
                catalog_price => 0.00,
                option_id => 123
            }
        ]
    );

    print "the order was created with the order_number: $order_number\n";

=cut
sub order_place
{
    my ($self, %args) = @_;
    my $response = $self->_create_order(\%args);
    my $ref = $response->{order_place_response}->{order_place_result};
    $self->_validate_response($ref->{credentials});
    return $ref->{order_number};
}

=head2 order_track

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

=cut
sub order_track
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'order_track', %args );
    my $ref = $response->{order_track_response}->{order_track_result};
    $self->_validate_response($ref->{credentials});
    
    my $order = $ref->{order};
    
    # make the fulfillment items have the same fields at those in the order_items
    my %order_items;
    foreach my $order_item (@{ $order->{items}->{OrderItem} })
    {
        $order_items{$order_item->{order_item_id}} = $order_item;
    }
    foreach my $fulfillment (@{ $order->{fulfillments}->{Fulfillment} })
    {
        my $fulfillment_items = $fulfillment->{items}->{FulfillmentItem};
        my $total_items = @$fulfillment_items;
        for (my $i = 0; $i < $total_items; $i++)
        {
            my $order_item_id = $fulfillment_items->[$i]->{order_item_id};
            $fulfillment_items->[$i] = $order_items{$order_item_id};
        }
    }
    
    return $order;
}

=head2 order_list

This method returns a list of order numbers
(the Catalog API order numbers, not external_order_number)
that match a given external_user_id.


    my $order_list_response = $api->order_list(
        external_user_id => 'johndoe123',
        per_page => 10,
        page => 1,
        );
    
    my $pager = $order_list_response->{pager};
    print "Found $pager->{result_count} orders. Currently on page $pager->{page} of $pager->{last_page}.\n";
    
    my $orders = $order_list_response->{orders}->{OrderSummary};
    foreach my $order (@$orders)
    {
        print "found order $order->{order_number} which was placed on $order->{date_placed}\n";
    }

=cut
sub order_list
{
    my ($self, %args) = @_;
    my $response = $self->_make_get_request( method => 'order_list', %args );
    my $ref = $response->{order_list_response}->{order_list_result};
    $self->_validate_response($ref->{credentials});
    return $ref;
}

sub _make_get_request
{
    my ($self, %args) = @_;
    
    my $creds = $self->_generate_creds( method => $args{method} );
    my $method = delete $args{method};
    
    my $die_on_fault = delete $args{die_on_fault};
    $die_on_fault = 1 unless defined($die_on_fault);
    
    @args{keys %$creds} = values %$creds;
    my @params = map { $_ . '=' . uri_escape_utf8($args{$_}) } keys %args;
    my $uri = "https://$self->{endpoint}/$API_VERSION/rest/$method/?" . join('&', @params);
    
    my $response = $AGENT->get($uri);
    my $response_ref;
    eval {
        $response_ref = from_json($response->content);
    };
    if (my $decode_error = $@)
    {
        croak "invalid response: $decode_error";
    }
    if ($response->is_success || !$die_on_fault)
    {
        return $response_ref;
    }
    else
    {
        if ($response_ref->{Fault}->{detail})
        {
            carp "$response_ref->{Fault}->{detail}";
        }
        die $response_ref->{Fault}->{faultcode} . ': ' . $response_ref->{Fault}->{faultstring} . "\n";
    }
}

sub _create_order
{
    my ($self, $order_ref) = @_;
    
    my $method = 'order_place';
    
    my $creds = $self->_generate_creds( method => $method );
    
    # wrap the request
    my $order_ref = {
        order_place => {
            order_place_request => $order_ref,
        },
    };
    
    my $creds = $self->_generate_creds( method => $method );
    $order_ref->{order_place}->{order_place_request}->{credentials} = {
        method => $method,
        checksum => $creds->{creds_checksum},
        datetime => $creds->{creds_datetime},
        uuid => $creds->{creds_uuid},
    };
    
    my $uri = "https://$self->{endpoint}/$API_VERSION/json/$method/";
    my $response = $AGENT->post($uri, Content => to_json($order_ref));
    my $response_ref;
    eval {
        $response_ref = from_json($response->content);
    };
    if (my $decode_error = $@)
    {
        croak "invalid response: $decode_error";
    }
    if ($response->is_success)
    {
        return $response_ref;
    }
    else
    {
        if ($response_ref->{Fault}->{detail})
        {
            carp "$response_ref->{Fault}->{detail}";
        }
        die $response_ref->{Fault}->{faultcode} . ': ' . $response_ref->{Fault}->{faultstring} . "\n";
    }
}

sub _generate_creds
{
    my ($self, %args) = @_;
    
    my $method = $args{method} || confess "method is a required arg";
    
    my $ug = new Data::UUID;
    my $uuid = $ug->to_string($ug->create());
    
    my $now = DateTime->now;
    $now->set_time_zone('UTC');
    my $datetime = $now->iso8601();
    
    my $checksum = encode_base64(hmac_sha1("$method$uuid$datetime", $self->{secret_key}), "");
    
    return {
        creds_uuid => $uuid,
        creds_datetime => $datetime,
        creds_checksum => $checksum,
    };
}

sub _validate_response
{
    my ($self, $creds) = @_;
    
    my $their_checksum = $creds->{checksum};
    my $our_checksum = encode_base64(hmac_sha1("$creds->{method}$creds->{uuid}$creds->{datetime}", $self->{secret_key}), "");
    if ($their_checksum ne $our_checksum)
    {
        confess "the returned checksum is invalid";
    }
    return;
}

1;
