use 5.008001;
use strict;
use warnings;

package MyFailures;

use custom::failures qw/io::file/;

use custom::failures 'Other::Failure' => [qw/io::file/];

1;
