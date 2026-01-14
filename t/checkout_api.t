#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Plack::Test;

use HTTP::Request::Common;
use lib 'lib';
use Checkout qw(calculate_subtotal);

use JSON::MaybeXS qw(decode_json encode_json);

my $app = do "./app.psgi";

my $test = Plack::Test->create($app);

#  Test 1: Check for empty cart
my $req = POST '/checkout',
    Content_Type => 'application/json',

    Content => encode_json({items => []});

my $res = $test->request($req);
ok($res->is_success(), 'Successful request');
is($res->content, encode_json({subtotal => 0}), 'return 0 for an empty cart');

# Test 2: Check for single item with special deals
$req = POST '/checkout',
    Content_Type => 'application/json',

    Content => encode_json({
        items => [{
                code     => 'A',
                quantity => 3
            }
        ]
    }
    );

$res = $test->request($req);
ok($res->is_success(), 'Successful request');
is(
    $res->content,
    encode_json({subtotal => 140}),
    'return correct total when the special offer for item A is applied'
);

# Test 3: Check if the quantity is below the special deal minimum
$req = POST '/checkout',
    Content_Type => 'application/json',

    Content => encode_json({
        items => [{
                code     => 'A',
                quantity => 2
            }
        ]
    }
    );

$res = $test->request($req);
ok($res->is_success(), 'Successful request');
is(
    $res->content,
    encode_json({subtotal => 100}),
    'should not apply special price if quantity is below special count'
);

# Test 4: Check for multiple special sets and a remainder
$req = POST '/checkout',
    Content_Type => 'application/json',

    Content => encode_json({
        items => [{
                code     => 'A',
                quantity => 7
            }
        ]
    }
    );

$res = $test->request($req);
ok($res->is_success(), 'Successful request');
is(
    $res->content,
    encode_json({subtotal => 330}),
    'should return correct total for multiple special sets and a remainder'
);

# Test 5: Check for a mix of items with and without special deals
$req = POST '/checkout',
    Content_Type => 'application/json',

    Content => encode_json({
        items => [{
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
    }
    );

$res = $test->request($req);
ok($res->is_success(), 'Successful request');
is(
    $res->content,
    encode_json({subtotal => 225}),
    'should return correct total for a mix of items with and without special deals'
);

# Test 6: Check for big mixed cart with all items
$req = POST '/checkout',
    Content_Type => 'application/json',

    Content => encode_json({
        items => [{
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
    }
    );

$res = $test->request($req);
ok($res->is_success(), 'Successful request');
is(
    $res->content,
    encode_json({subtotal => 447}),
    'should calculate a complex cart correctly'
);

# Test 7: Check for quantity 0 for multiple items
$req = POST '/checkout',
    Content_Type => 'application/json',

    Content => encode_json({
        items => [{
                code     => 'A',
                quantity => 0
            },
            {
                code     => 'B',
                quantity => 0
            }
        ]
    }
    );

$res = $test->request($req);
ok($res->is_success(), 'Successful request');
is(
    $res->content,
    encode_json({subtotal => 0}),
    'should return 0 if all items have quantity 0'
);

# Test 8: Check for 0 quantity for single item
$req = POST '/checkout',
    Content_Type => 'application/json',

    Content => encode_json({
        items => [{
                code     => 'A',
                quantity => 0
            }
        ]
    }
    );

$res = $test->request($req);
ok($res->is_success(), 'Successful request');
is(
    $res->content,
    encode_json({subtotal => 0}),
    'should return 0 for 0 quantity'
);
FIXME:
# Test 9: Check for a missing items field
# $req = POST '/checkout',
#     Content_Type => 'application/json',
#     Content      => encode_json({});

# $res = $test->request($req);
# is($res->code, 400, 'return 400 when items field is missing');
# my $json_res = decode_json($res->content);
# like($json_res->{error}, qr/Invalid item/, 'Error message matches');

# Test 10: Check if the item is not an array.
# $req = POST '/checkout',
#     Content_Type => 'application/json',
#     Content      => encode_json({items => "not an array"});

# $res = $test->request($req);
# is($res->code, 400, 'return 400 when items field is missing');
# $json_res = decode_json($res->content);
# like($json_res->{error}, qr/items must be an array/, 'Error message matches');

# Test 11: Check for an item with missing code
$req = POST '/checkout',
    Content_Type => 'application/json',
    Content      => encode_json({
        items => [{quantity => 1}]    # Missing quantity
    }
    );

$res = $test->request($req);
is($res->code, 400, 'returns 400 when code is missing');
my $json_res = decode_json($res->content);
like($json_res->{error}, qr/Code is required/, 'Error message matches');

# Test 12: Check if the item code is not a string.
$req = POST '/checkout',
    Content_Type => 'application/json',
    Content      => encode_json({
        items => [{code => 123, quantity => 1}]    # Missing quantity
    }
    );

$res = $test->request($req);
is($res->code, 400, 'Returns 400 when code is not a string');
$json_res = decode_json($res->content);
like($json_res->{error}, qr/code must be a string/, 'Error message matches');

TODO:
# Test 13: Check if the item code is empty string with space.
# Test 14: Check for an item with missing quantity
# Test 15: Check for negative quantity
# Test 16: Check for duplicate items in the cart
# Test 17: Check for invalid item code
# Test 18: Check for uppercase item codes
done_testing;
