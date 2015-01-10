#!/usr/bin/perl
use 5.006;
use strict;
use warnings;

# ABSTRACT: Serve up the contents of a hash as a website

package Plack::App::Hash;
use parent 'Plack::Component';

use Plack::Util ();
use Array::RefElem ();
use HTTP::Status ();
#use Digest::SHA;

use Plack::Util::Accessor qw( content headers auto_type default_type );

sub call {
	my $self = shift;
	my $env  = shift;

	my $path = $env->{'PATH_INFO'} || '';
	$path =~ s!\A/!!;

	my $content = $self->content;
	return $self->error( 404 ) unless $content and exists $content->{ $path };
	return $self->error( 500 ) if ref $content->{ $path };

	my $headers = ( $self->headers || $self->headers( {} ) )->{ $path };

	if ( not defined $headers ) {
		$headers = [];
	}
	elsif ( not ref $headers ) {
		require JSON::XS;
		$headers = JSON::XS::decode_json $headers;
	}

	return $self->error( 500 ) if 'ARRAY' ne ref $headers;

	{
		my $auto    = $self->auto_type;
		my $default = $self->default_type;
		last unless $auto or $default;
		last if Plack::Util::header_exists $headers, 'Content-Type';
		$auto &&= do { require Plack::MIME; Plack::MIME->mime_type( $path ) };
		Plack::Util::header_push $headers, 'Content-Type' => $_ for $auto || $default || ();
	}

	if ( not Plack::Util::header_exists $headers, 'Content-Length' ) {
		Plack::Util::header_push $headers, 'Content-Length' => length $content->{ $path };
	}

	my @body;
	Array::RefElem::av_push @body, $content->{ $path };
	return [ 200, $headers, \@body ];
}

sub error {
	my $status = pop;
	my $pkg = __PACKAGE__;
	my $body = [ qq(<!DOCTYPE html>\n<title>$pkg $status</title><h1><font face=sans-serif>) . HTTP::Status::status_message $status ];
	return [ $status, [
		'Content-Type'   => 'text/html',
		'Content-Length' => length $body->[0],
	], $body ];
}

1;

__END__

=head1 SYNOPSIS

 use Plack::App::Hash;
 my $app = Plack::App::Hash->new(
     content      => { '' => 'Hello World!' },
     default_type => 'text/plain',
 )->to_app;

=head1 DESCRIPTION

XXX

=head1 CONFIGURATION

=over 4

=item C<content>

XXX

=item C<headers>

XXX JSON

=item C<auto_type>

XXX

=item C<default_type>

XXX

=back
