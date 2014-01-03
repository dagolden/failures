use 5.008001;
use strict;
use warnings;

package failures;
# ABSTRACT: Minimalist exception hierarchy generator
# VERSION

sub import {
    no strict 'refs';
    my ( $class, @failures ) = @_;
    my $caller    = caller;
    my $is_custom = $class eq 'custom::failures';
    if ( $is_custom && ref $failures[1] eq 'ARRAY' ) {
        $caller   = shift @failures;
        @failures = @{ $failures[0] };
    }
    for my $f (@failures) {
        # XXX should check $f for valid package name
        my $custom  = $caller;
        my $default = 'failure';
        push @{"$custom\::ISA"}, $default if $is_custom;
        for my $p ( split /::/, $f ) {
            push @{"$default\::$p\::ISA"}, $default;
            $default .= "::$p";
            if ($is_custom) {
                push @{"$custom\::$p\::ISA"}, $custom, $default;
                $custom .= "::$p";
            }
        }
    }
}

package failure;

use Class::Tiny { msg => '', trace => '', payload => undef };

use overload ( q{""} => \&as_string, fallback => 1 );

sub throw {
    my ( $class, $msg ) = @_;
    my $m = ref $msg eq 'HASH' ? $msg : { msg => $msg };
    die $class->new( map { defined $m->{$_} ? ( $_ => $m->{$_} ) : () } keys %$m );
}

sub message {
    my ( $self, $msg ) = @_;
    my $intro = "Caught @{[ref $self]}";
    return defined($msg) && length($msg) ? "$intro: $msg" : $intro;
}

sub as_string {
    my ($self) = @_;
    my ( $message, $trace ) = ( $self->message( $self->msg ), $self->trace );
    return length($trace) ? "$message\n\n$trace\n" : "$message\n";
}

sub line_trace {
    my ( undef, $filename, $line ) = caller(0);
    return "Failure caught at $filename line $line.";
}

for my $fn (qw/croak_trace confess_trace/) {
    no strict 'refs';
    no warnings 'once';
    *{$fn} = sub {
        require Carp;
        local @failure::CARP_NOT = ( scalar caller );
        chomp( my $trace = $fn eq 'croak_trace' ? Carp::shortmess('') : Carp::longmess('') );
        return "Failure caught$trace";
    };
}

1;

=for Pod::Coverage throw message as_string

=head1 SYNOPSIS

    use failures qw/io::file io::network/;
    use Try::Tiny;
    use Safe::Isa; # for $_isa

    try {
        process_file or
            failure::io::file->throw("oops, something bad happened: $!");
    }
    catch {
        if   ( $_->$_isa("failure::io::file") ) {
            ...
        }
        elsif( $_->$_isa("failure::io") ) {
            ...
        }
        elsif( $_->$_isa("failure") ) {
            ...
        }
        else {
            ...
        }
    }

=head1 DESCRIPTION

This module lets you define an exception hierarchy quickly and simply.

Here were my design goals:

=for :list
* minimalist interface
* 80% of features in 20% of lines of code
* depend only on core modules (nearly achieved)
* support hierarchical error types
* identify errors types by name (class) not by parsing strings
* leave (possibly expensive) trace decisions to the thrower

Currently, C<failures> is implemented in under 70 lines of code.

Failure objects are implemented with L<Class::Tiny> to allow easy subclassing
(see L<custom::failures>), but C<Class::Tiny> only requires core modules, so
other than that exception, the 'core only' goal is achieved.

=head1 USAGE

=head2 Defining failure categories

    use failures qw/foo::bar foo::baz/;

This will define the following classes in the C<failure> namespace:

=for :list
* C<failure>
* C<failure::foo>
* C<failure::foo::bar>
* C<failure::foo::baz>

Subclasses inherit, so C<failure::foo::bar> is-a C<failure::foo> and
C<failure::foo> is-a C<failure>.

=head2 Throwing failures

The C<throw> method of a failure class takes a single, optional argument
that modifies how failure objects are stringified.

If no argument is given, a default message is generated:

    say failure::foo::bar->throw;
    # Caught failure::foo::bar

With a single, non-hash-reference argument, the argument is appended as a string:

    say failure::foo::bar->throw("Ouch!");
    # Caught failure::foo::bar: Ouch!

With a hash reference argument, the C<msg> key provides the string to append to
the default error.  If you have extra data to attach to the exception, use the
C<payload> key:

    failure::foo::bar->throw({
        msg     => "Ouch!",
        payload => $extra_data,
    });

If an optional C<trace> key is provided, it is appended as a string.  To
loosely emulate C<die> and provide a simple filename and line number, use the
C<< failure->line_trace >> class method:

    failure::foo::bar->throw({
        msg => "Ouch!",
        trace => failure->line_trace,
    });

    # Caught failure::foo::bar: Ouch!
    #
    # Failure caught at <FILENAME> line <NUMBER>

To provide a trace just like the L<Carp> module (including respecting C<@CARP_NOT>)
use the C<croak_trace> or C<confess_trace> class methods:

    failure::foo::bar->throw({
        msg => "Ouch!",
        trace => failure->croak_trace,
    });

    # Caught failure::foo::bar: Ouch!
    #
    # Failure caught at <CALLING-FILENAME> line <NUMBER>

    failure::foo::bar->throw({
        msg => "Ouch!",
        trace => failure->confess_trace,
    });

    # Caught failure::foo::bar: Ouch!
    #
    # Failure caught at <FILENAME> line <NUMBER>
    #   [confess stack trace continues]

You can provide a C<trace> key with any object that overrides stringification,
like L<Devel::StackTrace>:

    failure::foo::bar->throw({
        msg => "Ouch!",
        trace => Devel::StackTrace->new,
    });

    # Caught failure::foo::bar: Ouch!
    #
    # [stringified Devel::StackTrace object]

=head2 Catching failures

Use L<Try::Tiny>, of course.  Within a catch block, you know that C<$_>
is defined, but it still might be an unblessed reference or something that
is risky to call C<isa> on.  If you load L<Safe::Isa>, you get a code
reference in C<$_isa> that calls C<isa> only on objects.

So catching looks like this:

    use Try::Tiny;
    use Safe::Isa;

    try { ... }
    catch {
        if ( $_->$_isa("failure::foo") ) {
            # handle it
        }
    };

To extract the message just use the msg access.

    if ( $_->$_isa("failure::foo") ) {
        print $_->msg;
    }

If you need to rethrow the exception, just use C<die>:

    elsif ( $_->$_isa("failure") ) {
        die $_;
    }

=head2 Overriding failure class behavior

See L<custom::failures>.

=head1 SEE ALSO

There are many error/exception systems on CPAN.  This one is designed to be
minimalist.

If you have more complex or substantial needs, people I know and trust
seem to be recommending:

=for :list
* L<Throwable> — exceptions as a Moo/Moose role
* L<Throwable::X> — Throwable extended with extra goodies

Here are other modules I found that weren't appropriate for my needs or didn't
suit my taste:

=for :list
* L<Class::Throwable> — no hierarchy and always builds a full stack trace
* L<Error::Tiny> — blends Try::Tiny and a trivial exception base class
* L<Exception::Base> — complexity on par with Exception::Class, but highly optimized for speed
* L<Exception::Class> — once highly recommended, but even the author now suggests Throwable
* L<Exception::Simple> — very simple, but always uses C<caller> and has no hierarchy
* L<Exception::Tiny> — not bad, but always uses C<caller> and setting up a hierarchy requires extra work
* L<Ouch> — simple, well-thought out, but no hierarchy; also cutesy function names

Here are some that I'm very dubious about:

=for :list
* L<Err> — alpha since 2012
* L<Error> — no longer recommended by maintainer
* L<errors> — "still under design" since 2009
* L<Exception> — dates back to 1996 and undocumented

=cut

# vim: ts=4 sts=4 sw=4 et:
