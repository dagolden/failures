use 5.008001;
use strict;
use warnings;

package failures;
# ABSTRACT: Minimalist exception hierarchy generator
# VERSION

sub import {
    my ( $class, @failures ) = @_;
    for my $f (@failures) {
        my $fragment = 'failure';
        for my $p ( split /::/, $f ) {
            no strict 'refs';
            @{"$fragment\::$p\::ISA"} = $fragment;
            $fragment .= "::$p";
        }
    }
}

package failure;

use overload (
    q{""}    => \&as_string,
    fallback => 1,
);

sub throw {
    my ( $class, $msg ) = @_;
    my $self = ref $msg eq 'HASH' ? {%$msg} : { msg => $msg };
    die( bless( $self, $class ) );
}

sub message {
    my $msg = $_[0]->{msg};
    return ( defined $msg && length $msg ? $msg : '' );
}

sub trace {
    my $trace = $_[0]->{trace};
    return ( defined $trace && length $trace ? $trace : '' );
}

sub as_string {
    my ($self) = @_;
    ( my $type = ref $self ) =~ s/^failure:://;
    my ( $string, $msg, $trace ) =
      ( "Failed: $type error", $self->message, $self->trace );
    $string .= ": $msg"     if length $msg;
    $string .= "\n\n$trace" if length $trace;
    $string .= "\n";
    return $string;
}

sub line_trace {
    my ( $package, $filename, $line ) = caller(0);
    return "Failure caught at $filename line $line.";
}

for my $fn (qw/croak_trace confess_trace/) {
    no strict 'refs';
    *{$fn} = sub {
        require Carp;
        local @failure::CARP_NOT = ( scalar caller );
        my $trace = $fn eq 'croak_trace' ? Carp::shortmess('') : Carp::longmess('');
        chomp $trace;
        return "Failure caught$trace";
    };
}

1;

=for Pod::Coverage throw message as_string

=head1 SYNOPSIS

    use failures qw/io::file io::network/;
    use Try::Tiny;

    try {
        process_file or
            failure::io::file->throw("oops, something bad happened: $!");
    }
    catch {
        if   ( $_->isa("failure::io::file") ) {
            ...
        }
        elsif( $_->isa("failure::io") ) {
            ...
        }
        elsif( $_->isa("failure") ) {
            ...
        }
        else {
            ...
        }
    }

=head1 DESCRIPTION

This module lets you define an exception hierarchy with very little code.

=head1 USAGE

=head2 Defining failure categories

    use failures qw/foo::bar foo::baz/;

This will define the following failure classes:

=for :list
* failure
* failure::foo
* failure::foo::bar
* failure::foo::baz

Subclasses inherit, so C<failure::foo::bar> C<isa> C<failure::foo> and C<isa>
C<failure>.

=head2 Throwing failures

The C<throw> method of a failure class takes a single, optional argument
that modifies how failure objects are stringified.

If no argument is given, a default message is generated:

    say failure::foo::bar->throw;
    # Failed: foo::bar error

With a single, non-hash-reference argument, the argument is appended as a string:

    say failure::foo::bar->throw("Ouch!");
    # Failed: foo::bar error: Ouch!

With a hash reference argument, the C<msg> key provides the string to append to
the default error.  If an optional C<trace> key is provided, it is appended as
a string.  To vaguely emulate C<die> and provide a simple filename and line
number, use the C<< failure->line_trace >> class method:

    failure::foo::bar->throw({
        msg => "Ouch!",
        trace => failure->line_trace,
    });

    # Failed: foo::bar error: Ouch!
    #
    # Failure caught at <FILENAME> line <NUMBER>

To provide a trace just like the L<Carp> module (including respecting C<@CARP_NOT>)
use the C<croak_trace> or C<confess_trace> class methods.

    failure::foo::bar->throw({
        msg => "Ouch!",
        trace => failure->croak_trace,
    });

    # Failed: foo::bar error: Ouch!
    #
    # Failure caught at <CALLING-FILENAME> line <NUMBER>

    failure::foo::bar->throw({
        msg => "Ouch!",
        trace => failure->confess_trace,
    });

    # Failed: foo::bar error: Ouch!
    #
    # Failure caught at <FILENAME> line <NUMBER>
    #   [confess stack trace continues]

You can provide a C<trace> key with any object that overrides stringification,
like L<Devel::StackTrace>:

    failure::foo::bar->throw({
        msg => "Ouch!",
        trace => Devel::StackTrace->new,
    });

    # Failed: foo::bar error: Ouch!
    #
    # [stringified Devel::StackTrace object]

=head2 Catching failures

Use L<Try::Tiny>, of course.  Within a catch block, you know that C<$_>
is defined, so you can test with C<isa>.

    try { ... }
    catch {
        if ( $_->isa("failure::foo") ) {
            # handle it
        }
    };

=head1 SEE ALSO

There is no shortage of error/exception systems on CPAN.  This one is
designed to be minimalist.

If you have more complex or substantial needs, you might (or might not) want to
explore include:

=for :list
* L<Throwable::X> — for Moo/Moose classes
* L<Exception::Class> -- for non-Moo/Moose classes
* … more to come …

=cut

# vim: ts=4 sts=4 sw=4 et:
