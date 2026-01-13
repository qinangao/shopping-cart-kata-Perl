
use strict;
use warnings;
use Plack::Request;
use lib 'lib';
use Checkout qw(calculate_subtotal);

# my $app_or_middleware = sub {
#     my $env = shift; # PSGI env
#     my $req = Plack::Request->new($env);
#     my $path_info = $req->path_info;
#     my $query     = $req->parameters->{query};
#     my $res = $req->new_response(200); # new Plack::Response
#     $res->finalize;
# };

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

};
