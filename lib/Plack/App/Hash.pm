#!/usr/bin/perl
use strict;
use warnings;

# ABSTRACT: Serve up the contents of a hash as a website

package Plack::App::Hash;
use parent 'Plack::Component';

use Plack::Util ();
use Array::RefElem ();
use HTTP::Status ();
#use Digest::SHA;

use Plack::Util::Accessor qw( content headers default_type );

sub call {
	my $self = shift;
	my $env  = shift;

	my $path = $env->{PATH_INFO} || '';
	$path =~ s!\A/!!;

	my $content = $self->content;
	return $self->error( 404 ) unless $content and exists $content->{ $path };

	my $headers = $self->headers;
	my $hdrs = ( $headers and exists $headers->{ $path } ) ? $headers->{ $path } : [];
	if ( not ref $hdrs ) {
		require JSON::XS;
		$hdrs = JSON::XS::decode_json $hdrs;
	}

	if ( my $default = $self->default_type ) {
		Plack::Util::header_push $hdrs, 'Content-Type' => $default
			if not Plack::Util::header_exists $hdrs, 'Content-Type';
	}

	if ( not Plack::Util::header_exists $hdrs, 'Content-Length' ) {
		Plack::Util::header_push $hdrs, 'Content-Length' => length $content->{ $path };
	}

	my $body = [];
	Array::RefElem::av_push @$body, $content->{ $path };
	return [ 200, $hdrs, $body ];
}

sub error {
	my $status = pop;
	my $body = [ qq(<!doctype html>\n<title>$status</title><h1><font face=sans-serif>) . HTTP::Status::status_message $status ];
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

=item C<default_type>

XXX

=back
