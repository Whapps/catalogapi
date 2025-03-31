package CatalogAPI::SQLite;

use strict;
use warnings FATAL => 'all';
no warnings FATAL => 'uninitialized';

=head1 NAME

CatalogAPI::SQLite - Can be used to connect to the SQLite catalog extracts

=head1 SYNOPSIS

    use CatalogAPI::SQLite;

    my $dbfile = 'catalog-12345.sqlite';
    my $catalog = CatalogAPI::SQLite->new(
        filename => $dbfile
    );

    # Do a query 
    my $items = $catalog->manager('CatalogItem')->get_objects();

=cut

our $VERSION = 1;
use Rose::DB;

Rose::DB->register_db(
    domain => 'catalog',
    type   => 'main',
    driver => 'sqlite',
);
Rose::DB->default_domain('catalog');
Rose::DB->default_type('main');

# Delay the loading of the object classes until we are loaded,
# otherwise the circular dependency causes an error
INIT
{
    require CatalogAPI::SQLite::Brand::Manager;
    require CatalogAPI::SQLite::Catalog::Manager;
    require CatalogAPI::SQLite::CatalogItem::Manager;
    require CatalogAPI::SQLite::CatalogItemCategory::Manager;
    require CatalogAPI::SQLite::CatalogItemSupplierPrice::Manager;
    require CatalogAPI::SQLite::CatalogItemTag::Manager;
    require CatalogAPI::SQLite::Category::Manager;
    require CatalogAPI::SQLite::Collection::Manager;
    require CatalogAPI::SQLite::Search::Manager;
    require CatalogAPI::SQLite::Tag::Manager;
    require CatalogAPI::SQLite::TagCategory::Manager;
};

=head2 new

Connect to the DB file.

=cut

sub new
{
    my ( $class, %args ) = @_;

    my $db_file = delete( $args{filename} );
    my $db;

    if ($db_file)
    {
        $db = Rose::DB->new( database => $db_file );
    }
    else
    {
        $db = Rose::DB->new();
    }

    my $self = bless \%args, $class;

    $self->db($db);

    return $self;
}

=head2 rose

Shortcut for rose prefix for convention

=cut

sub rose
{
    my ( $self, $class ) = @_;
    return "CatalogAPI::SQLite::$class";
}

=head2 manager

Shortcut for manager prefix for convention

=cut

sub manager
{
    my ( $self, $class ) = @_;
    return 'CatalogAPI::SQLite::' . $class . '::Manager';
}

=head2 db

Accessor for db

=cut

sub db
{
    my ( $self, $db ) = @_;

    if ( defined($db) )
    {
        $self->{_db} = $db;
    }

    return $self->{_db};
}
