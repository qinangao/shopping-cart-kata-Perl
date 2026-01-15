#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;         # is  ($got, $expected, $test_name);
use Test::Exception;    # throws_ok( sub { $foo->method }, qr/division by zero/,'zero caught okay' );
use lib 'lib';
use Checkout qw(calculate_subtotal);

# Test 1: Check for empty cart
is(calculate_subtotal([]), 0, 'return 0 for an empty cart');

# Test 2: Check for single item, no special deals
is(
    calculate_subtotal([{code => 'C', quantity => 1}]),
    25,
    '1 unit of C costs 25'
);

# Test 3 : Check for single item with special deal
is(
    calculate_subtotal([{code => 'A', quantity => 3}]),
    140,
    '3 units of A cost 140'
);

# Test 4: Check if the quantity is below the special deal minimum
is(
    calculate_subtotal([{code => 'A', quantity => 2}]),
    100,
    '2 units of A cost 100'
);

# Test 5: Check for multiple special sets and a remainder
is(
    calculate_subtotal([{code => 'A', quantity => 7}]),
    330,
    '7 units of A cost 330'
);

# Test 6: Check for a mix of items with and without special deals
is(
    calculate_subtotal(
        [{
                code     => 'A',
                quantity => 3
            },
            {
                code     => 'B',
                quantity => 2
            },
            {
                code     => 'C',
                quantity => 1
            }
        ]
    ),
    225,
    '3 units of A, 2 units of B and 1 unit of C cost 330'
);

# Test 7: Check for big mixed cart with all items
is(
    calculate_subtotal(
        [{
                code     => 'A',
                quantity => 5
            },
            {
                code     => 'B',
                quantity => 4
            },
            {
                code     => 'C',
                quantity => 3
            },
            {
                code     => 'D',
                quantity => 1
            }
        ]
    ),
    447,
    '5 units of A, 4 units of B, 3 units of C and 1 unit of D cost 447'
);

# Test 8: Check for duplicate items in the cart
throws_ok(
    sub {
        calculate_subtotal(
            [{
                    code     => 'A',
                    quantity => 2
                },
                {
                    code     => 'A',
                    quantity => 1
                },
            ]
        );
    },
    qr/Duplicate item A is not allowed/,
    'throw an error for Duplicate item'
);

# Test 9: Check for quantity 0 for multiple items
is(
    calculate_subtotal([{
                code     => 'A',
                quantity => 0
            },
            {
                code     => 'B',
                quantity => 0
            },
        ]
    ),
    0,
    'return 0 if all items have quantity 0'
);

# Test 10: Check for 0 quantity
is(
    calculate_subtotal([{
                code     => 'A',
                quantity => 0
            }
        ]
    ),
    0,
    'return 0 for 0 quantity'
);

# Test 11: Check for invalid item code
throws_ok(
    sub {
        calculate_subtotal(
            [{
                    code     => 'Z',
                    quantity => 1
                }
            ]
        );
    },
    qr/Product Z doesn't exist/,
    'throw an error for an invalid item code'
);

# Test 12: Check for missing fields
throws_ok(
    sub {
        calculate_subtotal(
            [{quantity => 1}]
        );
    },
    qr/Code is required/,
    'throw an error for missing fields'
);

# Test 13: Check for null or undefined items inside the array
throws_ok(
    sub {
        calculate_subtotal(
            [undef]
        );
    },
    qr/Invalid item/,
    'throw an error for undefined item'
);

# Test 14: Check for uppercase item codes
throws_ok(
    sub {
        calculate_subtotal(
            [{
                    code     => 'a',
                    quantity => 1
                }
            ]
        );
    },
    qr/Product a doesn't exist/,
    'throw an error for an invalid item code'
);

done_testing;
