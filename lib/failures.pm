use v5.10;
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
    my ( $self, $type, $msg ) = @_;
    my $string = "Failed: $type error";
    $string .= ": $msg" if defined $msg && length $msg;
    return $string;
}

sub as_string {
    my ($self) = @_;
    ( my $class = ref $self ) =~ s/^failure:://;
    my $msg = $self->message( $class, $self->{msg} );
    $msg .= "\n\n@{[$self->{trace}]}" if defined $self->{trace};
    return $msg;
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

With a hash reference argument, the C<msg> key provides the string to append
to the default error.  If an optional C<trace> key is provided, it is appended
as a string.

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

Others you might (or might not) want to explore include:

=for :list
* L<Throwable::X> — for Moo/Moose classes
* L<Exception::Class> -- for non-Moo/Moose classes
* ...[more to come]...

=cut

# vim: ts=4 sts=4 sw=4 et:
