#
# This file is part of App-CPAN2Pkg
#
# This software is copyright (c) 2009 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.010;
use strict;
use warnings;

package App::CPAN2Pkg::Worker::Mageia;
BEGIN {
  $App::CPAN2Pkg::Worker::Mageia::VERSION = '2.111781';
}
# ABSTRACT: worker dedicated to Mageia distribution

use HTML::TreeBuilder;
use HTTP::Request;
use Moose;
use MooseX::ClassAttribute;
use MooseX::Has::Sugar;
use MooseX::POE;
use POE;
use POE::Component::Client::HTTP;
use Readonly;

extends 'App::CPAN2Pkg::Worker::RPM';

Readonly my $K => $poe_kernel;

# -- class attribute

class_has _ua => ( ro, isa=>'Str', builder=>"_build__ua" );

sub _build__ua {
    my $ua = "mageia-bswait";
    POE::Component::Client::HTTP->spawn( Alias => $ua );
    return $ua;
}


# -- public methods

override cpan2dist_flavour => sub { "CPANPLUS::Dist::Mageia" };


# -- cpan2pkg logic implementation

{   # check_upstream_availability
    override check_upstream_availability => sub {
        my $self = shift;
        my $modname = $self->module->name;

        my $cmd = "urpmq --whatprovides 'perl($modname)'";
        $K->post( main => log_step => $modname => "Checking if module is packaged upstream");
        $self->run_command( $cmd => "_check_upstream_availability_result" );
    };
}

{   # install_from_upstream
    override install_from_upstream => sub {
        super();
        $K->yield( get_rpm_lock => "_install_from_upstream_with_rpm_lock" );
    };

    #
    # _install_from_upstream_with_rpm_lock( )
    #
    # really install module from distribution, now that we have a lock
    # on rpm operations.
    #
    event _install_from_upstream_with_rpm_lock => sub {
        my $self = shift;
        my $modname = $self->module->name;
        my $cmd = "sudo urpmi --auto 'perl($modname)'";
        $self->run_command( $cmd => "_install_from_upstream_result" );
    };
}

{ # upstream_import_package
    override upstream_import_package => sub {
        super();
        my $self = shift;
        my $srpm = $self->srpm;
        my $cmd = "mgarepo import $srpm";
        $self->run_command( $cmd => "_upstram_import_package_result" );
    };
}

{ # upstream_build_package
    override upstream_build_package => sub {
        super();
        my $self = shift;
        my $pkgname = $self->srpm->basename;
        $pkgname =~ s/-\d.*$//;
        my $cmd = "mgarepo submit $pkgname";
        $self->run_command( $cmd => "_upstram_build_package_result" );
    };

    override _upstream_build_wait => sub {
        my $self = shift;
        $self->yield( "_upstream_build_wait_request" );
    };

    event _upstream_build_wait_request => sub {
        my $self = shift;
        my $url = "http://pkgsubmit.mageia.org/";
        my $request = HTTP::Request->new(GET => $url);
        $K->post( $self->_ua => request => _upstream_build_wait_answer => $request );
    };

    event _upstream_build_wait_answer => sub {
        my ($self, $requests, $answers) = @_[OBJECT, ARG0, ARG1];
        my $answer = $answers->[0];
        my $pkg = $self->srpm->basename;
        $pkg =~ s/\.src.rpm$//;

        my $tree  = HTML::TreeBuilder->new_from_content( $answer->as_string );
        my $table = $tree->find_by_tag_name('table');
        my $link  = $table->look_down(
            _tag => "a",
            sub {
                my ($text) = $_[0]->content_list;
                $text =~ /$pkg/;
            }
        );
        my (@cells)  = $link->parent->parent->content_list;
        my ($status) = $cells[6]->content_list;
        ($status) = $status->content_list if ref($status);
        $status = "unknown" if ref($status);

        my $modname = $self->module->name;
        given ( $status ) {
            when ( "uploaded" ) {
                # nice, we finally made it!
                my $min = 3;
                $K->post( main => log_comment => $modname =>
                    "module successfully built, waiting $min minutes to index it" );
                # wait some time to be sure package has been indexed
                $K->delay( _upstream_build_package_ready => $min * 60 );
            }
            when ( "failure" ) {
                my $url = "http://pkgsubmit.mageia.org/" . $status->attr("href");
                $self->yield( _upstream_build_package_failed => $url );
            }
            default {
                # no definitive result, wait a bit before checking again
                $K->post( main => log_comment => $modname =>
                    "still not ready (current status: $status), waiting 1 more minute" );
                $K->delay( _upstream_build_wait_request => 60 );
            }
        }
    };
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;


=pod

=head1 NAME

App::CPAN2Pkg::Worker::Mageia - worker dedicated to Mageia distribution

=head1 VERSION

version 2.111781

=head1 DESCRIPTION

This class implements Mageia specificities that a general worker doesn't
know how to handle. It inherits from L<App::CPAN2Pkg::Worker::RPM>.

=head1 AUTHOR

Jerome Quelin <jquelin@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

