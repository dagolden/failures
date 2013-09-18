use 5.008001;
use strict;
use warnings;

package MyFailures;

use custom::failures qw/io::file/;

use Class::Tiny {
    when => sub { time }
};

sub message {
    my ( $self, $msg ) = @_;
    my $when = sprintf( "(%s)", $self->when );
    return $self->SUPER::message( length($msg) ? "$when $msg" : $when );
}

package main;

use custom::failures 'Other::Failure' => [qw/io::file/];

1;
