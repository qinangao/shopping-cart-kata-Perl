use strict;
use warnings;
use JSON::MaybeXS qw(decode_json encode_json);
use Plack::Request;
use lib 'lib';
use Checkout qw(calculate_subtotal);

# Error handler
sub _error_response {
    my ($error_msg, $status) = @_;

    $error_msg =~ s/\s+$//;
    $error_msg =~ s/[^\w\s\.\,\:\'\@\-]/?/g;

    return [
        $status || 400,
        ['Content-Type' => 'application/json'],
        [encode_json({error => $error_msg})],
    ];
}

# Entry point
my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    if ($req->method eq 'POST' && $req->path eq '/checkout') {

        my $body = $req->content;
        my $data;

        eval {$data = decode_json($body)};

        if ($@) {
            return _error_response("Invalid JSON", 400);
        }

        my $subtotal = eval {calculate_subtotal($data->{items});};

        if ($@) {
            return _error_response($@, 400);
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
