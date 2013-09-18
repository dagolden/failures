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

    package MyApp::failure;

    use custom::failures qw/io::file io::network/;

    # customize failure methods…

=head1 DESCRIPTION

This module works like L<failures> but lets you define a customized exception
hierarchy if you need a custom namespace or customized object behaviors.

=head1 USAGE

=head2 Defining a custom failure hierarchy

    package MyApp::failure;

    use custom::failures qw/foo::bar/;

This will define a failure class hierarchy under the calling package's
namespace.  The following diagram show the classes that will be created (arrows
denote 'is-a' relationships):

    MyApp::failure::foo::bar --> failure::foo::bar
           |                        |
           V                        V
    MyApp::failure::foo      --> failure::foo
           |                        |
           V                        V
    MyApp::failure           --> failure

Alternatively, if you want a different namespace for the hierarchy, do it this way:

    use custom::failures 'MyApp::Error' => [ 'io::file' ];

That will create the following classes and relationships:

    MyApp::Error::foo::bar --> failure::foo::bar
           |                        |
           V                        V
    MyApp::Error::foo      --> failure::foo
           |                        |
           V                        V
    MyApp::Error           --> failure

=head2 Overriding failure class behavior (experimental)

Because failure classes have an C<@ISA> chain and Perl by default uses
depth-first-search to resolve method calls, you can override behavior anywhere
in in the custom hierarchy and it will take precedence over default C<failure>
behaviors.

=cut

# vim: ts=4 sts=4 sw=4 et:
