use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;

use failures qw/vogon jeltz/;

eval { failure::vogon->throw };
ok( my $err = $@, 'caught throw error' );
isa_ok( $err, $_ ) for qw/failure failure::vogon/;

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
