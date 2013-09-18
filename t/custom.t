use 5.008001;
use strict;
use warnings;
use Test::More 0.96;

# use if available
eval { require Test::FailWarnings; Test::FailWarnings->import };

use lib 't/lib';
use MyFailures;

subtest 'custom hierarchy' => sub {
    my @parts = qw/MyFailures failure io file/;
    while (@parts) {
        my $class   = join( "::", @parts );
        my $last    = pop @parts;
        my $parent  = join( "::", @parts );
        my $sibling = join( "::", @parts[ 1 .. $#parts ], $last );
        isa_ok( $class, $parent,  $class ) if $parent =~ /failure/;
        isa_ok( $class, $sibling, $class ) if $sibling =~ /failure/;
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
