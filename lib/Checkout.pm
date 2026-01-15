package Checkout;

use strict;
use warnings;
use Exporter 'import';
use JSON::MaybeXS qw(decode_json);
use Path::Tiny;
use FindBin qw($Bin);

our @EXPORT_OK = qw(calculate_subtotal);

# Load data from JSON file
sub _load_products {

    my $file =
        path(__FILE__)->parent->parent->child('data', 'pricingData.json');
    warn "Loading pricing from: $file\n";

    my $data = decode_json($file->slurp_utf8);

    unless (ref $data eq 'HASH') {
        die 'pricingData.json must contain a JSON object';
    }

    return $data;
}

my $PRODUCTS = _load_products();

# Validation:
sub _validate_items {
    my ($items) = @_;

    unless (defined $items) {
        die "Items field is required";
    }

    unless (ref $items eq 'ARRAY') {
        die "Items must be an array";
    }

}

sub _validate_item {
    my ($item, $seen) = @_;

    # Check for Invalid items
    unless (defined $item && ref $item eq 'HASH') {
        die "Invalid item";
    }

    my $code     = $item->{code};
    my $quantity = $item->{quantity};

    # Check for missing fields
    unless (defined $code) {
        die "Code is required";
    }
    unless (defined $quantity) {
        die "Quantity is required";
    }

    unless ($quantity >= 0 && $quantity <= 1000) {
        die "Quantity must be between 0 and 1000";
    }

    # Check for duplicate items
    if ($seen->{$code}) {
        die "Duplicate item $code is not allowed\n";
    }
    $seen->{$code} = 1;

    # Check for invalid item code
    unless ($PRODUCTS->{$code}) {
        die "Product $code doesn't exist\n";
    }
}

# Business logic:
sub calculate_subtotal {
    my ($items) = @_;

    _validate_items($items);

    my $subtotal = 0;
    my %seen;

    for my $item (@$items) {

        _validate_item($item, \%seen);

        my $code     = $item->{code};
        my $quantity = $item->{quantity};

        my $unit_price = $PRODUCTS->{$code}{unit_price};

        if (my $special = $PRODUCTS->{$code}{special}) {
            my $special_count = $special->{count};
            my $special_price = $special->{price};

            if ($special_count > 0 && $special_price > 0) {
                my $num_specials = int($quantity / $special_count);
                my $remainder    = $quantity % $special_count;

                $subtotal +=
                    ($num_specials * $special_price) +
                    ($remainder * $unit_price);
                next;
            }
        } else {
            $subtotal += $unit_price * $quantity;
        }
    }

    return $subtotal;
}
1;
