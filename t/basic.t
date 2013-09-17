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

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
