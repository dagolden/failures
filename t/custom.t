use 5.008001;
use strict;
use warnings;
use Test::More 0.96;

# use if available
eval { require Test::FailWarnings; Test::FailWarnings->import };

use lib 't/lib';
use MyFailures;

subtest 'custom hierarchy' => sub {
    no strict 'refs';
    for ("MyFailures::io::file") {
        isa_ok( $_, "MyFailures::io",    $_ ) or diag explain \@{"$_\::ISA"};
        isa_ok( $_, "failure::io::file", $_ ) or diag explain \@{"$_\::ISA"};
    }
    for ("MyFailures::io") {
        isa_ok( $_, "MyFailures",  $_ ) or diag explain \@{"$_\::ISA"};
        isa_ok( $_, "failure::io", $_ ) or diag explain \@{"$_\::ISA"};
    }
    for ("MyFailures") {
        isa_ok( $_, "failure", $_ ) or diag explain \@{"$_\::ISA"};
    }
};

subtest 'custom hierarchy in custom namespace' => sub {
    no strict 'refs';
    for ("Other::Failure::io::file") {
        isa_ok( $_, "Other::Failure::io", $_ ) or diag explain \@{"$_\::ISA"};
        isa_ok( $_, "failure::io::file",  $_ ) or diag explain \@{"$_\::ISA"};
    }
    for ("Other::Failure::io") {
        isa_ok( $_, "Other::Failure", $_ ) or diag explain \@{"$_\::ISA"};
        isa_ok( $_, "failure::io",    $_ ) or diag explain \@{"$_\::ISA"};
    }
    for ("Other::Failure") {
        isa_ok( $_, "failure", $_ ) or diag explain \@{"$_\::ISA"};
    }
};

##subtest 'stringification' => sub {
##    my $err;
##    eval { failure::vogon::jeltz->throw };
##    ok( $err = $@, 'caught thrown error (no message)' );
##    is( "$err", "Failed: vogon::jeltz error\n", "stringification (no message)" );
##
##    eval { failure::vogon::jeltz->throw("bypass over budget") };
##    ok( $err = $@, 'caught thrown error (string message)' );
##    is(
##        "$err",
##        "Failed: vogon::jeltz error: bypass over budget\n",
##        "stringification (string message)"
##    );
##
##    eval { failure::vogon::jeltz->throw( { msg => "bypass over budget" } ) };
##    ok( $err = $@, 'caught thrown error (message in hashref)' );
##    is(
##        "$err",
##        "Failed: vogon::jeltz error: bypass over budget\n",
##        "stringification (message in hashref)"
##    );
##};

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
