use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;

use failures qw/vogon vogon::jeltz human::arthur/;

subtest 'throw unnested failure' => sub {
    my $err;
    eval { failure::vogon->throw };
    ok( $err = $@, 'caught thrown error' );
    isa_ok( $err, $_ ) for qw/failure failure::vogon/;
};

subtest 'throw nested failure' => sub {
    my $err;
    eval { failure::vogon::jeltz->throw };
    ok( $err = $@, 'caught thrown error' );
    isa_ok( $err, $_ ) for qw/failure failure::vogon failure::vogon::jeltz/;

    eval { failure::human::arthur->throw };
    ok( $err = $@, 'caught thrown error' );
    isa_ok( $err, $_ ) for qw/failure failure::human failure::human::arthur/;
};

subtest 'stringification' => sub {
    my $err;
    eval { failure::vogon::jeltz->throw };
    ok( $err = $@, 'caught thrown error (no message)' );
    is( "$err", "Failed: vogon::jeltz error", "stringification (no message)" );

    eval { failure::vogon::jeltz->throw("bypass over budget") };
    ok( $err = $@, 'caught thrown error (string message)' );
    is(
        "$err",
        "Failed: vogon::jeltz error: bypass over budget",
        "stringification (string message)"
    );

    eval { failure::vogon::jeltz->throw( { msg => "bypass over budget" } ) };
    ok( $err = $@, 'caught thrown error (message in hashref)' );
    is(
        "$err",
        "Failed: vogon::jeltz error: bypass over budget",
        "stringification (message in hashref)"
    );
};

subtest 'trace' => sub {
    my $err;
    eval { failure::vogon::jeltz->throw( { trace => 'STACK TRACE' } ) };
    ok( $err = $@, 'caught thrown error (with trace)' );
    is(
        "$err",
        "Failed: vogon::jeltz error\n\nSTACK TRACE",
        "stringification with stack trace"
    );
};

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
