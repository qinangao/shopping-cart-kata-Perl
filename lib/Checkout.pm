package Checkout;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(calculate_subtotal);

my $PRODUCTS = {
    A => {
        unit_price => 50,
        special    => {
            count => 3,
            price => 140
        }
    },
    B => {
        unit_price => 35,
        special    => {
            count => 2,
            price => 60
        }
    },
    C => {unitPrice => 25},
    D => {unitPrice => 12}
};

sub calculate_subtotal {
    my ($items) = @_;
    my $subtotal = 0;

    for my $item (@$items) {
        my $code       = $item->{code};
        my $quantity   = $item->{quantity};
        my $unit_price = $PRODUCTS->{$code}{unitPrice};

        $subtotal += $unit_price * $quantity;
    }

    return $subtotal;
}
1;
