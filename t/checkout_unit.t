#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;    # is  ($got, $expected, $test_name);
use lib 'lib';
use Checkout qw(calculate_subtotal);

# Test 1: Check for empty cart
is(calculate_subtotal([]), 0, 'Empty cart returns 0');

# Test 2: Check for single item, no special deals
is(
    calculate_subtotal([{code => 'C', quantity => 1}]),
    25,
    '1 Unit of C costs 25'
);

done_testing;
