requires 'perl', '5.006';
requires 'strict';
requires 'warnings';
requires 'parent';

requires 'Array::RefElem';
requires 'HTTP::Status';
requires 'JSON::MaybeXS';
requires 'Plack::Component';
requires 'Plack::MIME';
requires 'Plack::Util';
requires 'Plack::Util::Accessor';

on test => sub {
	requires 'HTTP::Request::Common';
	requires 'Plack::Test';
	requires 'Test::More', '0.88';
};

# vim: ft=perl
