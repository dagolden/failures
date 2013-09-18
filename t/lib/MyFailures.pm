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

sub throw {
    my ( $self, $msg ) = @_;
    $self->SUPER::throw( { msg => $msg, payload => "Hello Payload" } );
}

package main;

use custom::failures 'Other::Failure' => [qw/io::file/];

1;
