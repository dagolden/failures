use 5.008001;
use strict;
use warnings;

package custom::failures;
# ABSTRACT: Minimalist, but customized exception hierarchies
# VERSION

use parent 'failures';

1;

=for Pod::Coverage throw message as_string

=head1 SYNOPSIS

    package MyApp;

    use custom::failures qw/io::file io::network/;

=head1 DESCRIPTION

This module lets you define a customized exception hierarchy quickly and simply.
Behavior modified in customiezed failure classes take precedence over default
behaviors.

=head1 USAGE

=head2 Defining a custom 

    use custom::failures qw/foo::bar/;

    # Class hierarchy:
    # 
    # MyApp::failure::foo::bar --> failure::foo::bar
    #        |                        |
    #        V                        V
    # MyApp::failure::foo      --> failure::foo
    #        |                        |
    #        V                        V
    # MyApp::failure           --> failure

This will define the following failure classes:

=head2 Overriding failure class behavior (experimental)

Because failure classes have an C<@ISA> chain and Perl by default uses depth-first-search to
resolve method calls, you can override behavior anywhere in C<MyApp::failure::*> and it will
take precedence over default C<failure> behaviors.

=cut

# vim: ts=4 sts=4 sw=4 et:
