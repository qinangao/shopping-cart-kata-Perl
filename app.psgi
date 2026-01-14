use strict;
use warnings;
use JSON::MaybeXS qw(decode_json encode_json);
use Plack::Request;
use lib 'lib';
use Checkout qw(calculate_subtotal);

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    if ($req->method eq 'POST' && $req->path eq '/checkout') {

        my $body = $req->content;
        my $data;

        eval {$data = decode_json($body)};

        if ($@) {
            return [
                400,
                ['Content-Type' => 'application/json'],
                [encode_json({error => "Invalid JSON"})],
            ];
        }

        my $subtotal = eval {calculate_subtotal($data->{items});};

        if ($@) {
            my $error_msg = $@;
            chomp $error_msg;
            return [
                400,
                ['Content-Type' => 'application/json'],
                [encode_json({error => $error_msg})],
            ];
        }

        return [
            200,
            ['Content-Type' => 'application/json'],
            [encode_json({subtotal => $subtotal})],
        ];
    }

    return [404, ['Content-Type' => 'text/plain'], ['Page Not Found']];
};

$app;
