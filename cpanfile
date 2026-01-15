requires 'Plack',         '1.0048';
requires 'JSON::MaybeXS', '0';
requires 'Path::Tiny',    '0.144';

on 'test' => sub {
    requires 'Test::More',            '0.98';
    requires 'Test::Exception',       '0.43';
    requires 'HTTP::Request::Common', '6.22';
};
