#
# This file is part of App-CPAN2Pkg
#
# This software is copyright (c) 2009 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.012;
use warnings;
use strict;

package App::CPAN2Pkg::Types;
{
  $App::CPAN2Pkg::Types::VERSION = '2.120370';
}
# ABSTRACT: types used in the distribution

use Moose::Util::TypeConstraints;

enum Status => ( "not started", "not available", qw{ importing building installing available error } );

1;


=pod

=head1 NAME

App::CPAN2Pkg::Types - types used in the distribution

=head1 VERSION

version 2.120370

=head1 DESCRIPTION

This module implements the specific types used by the distribution, and
exports them (exporting is done by L<Moose::Util::TypeConstraints>).

=head1 AUTHOR

Jerome Quelin <jquelin@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

