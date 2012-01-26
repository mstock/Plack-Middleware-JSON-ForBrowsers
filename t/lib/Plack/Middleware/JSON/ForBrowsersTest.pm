package Plack::Middleware::JSON::ForBrowsersTest;
use base qw(Test::Class);

use strict;
use warnings;

use Test::More;
use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;


sub startup : Test(startup) {
	my ($self) = @_;
	$self->{app} = Plack::Util::load_psgi('examples/app.psgi');
}


sub basic_test : Test(6) {
	my ($self) = @_;

	test_psgi $self->{app}, sub {
		my ($cb) = @_;

		my $res = $cb->(GET "/json");
		is($res->header('content-type'), 'text/html; charset=utf-8', 'content type changed');
		like($res->content(), qr{<html}, 'response contains HTML');

		$res = $cb->(GET "/json", 'X-Requested-With' => 'XMLHttpRequest');
		is($res->header('content-type'), 'application/json', 'content type not changed');
		is($res->content(), '{"foo":"bar"}', 'response not modified');

		$res = $cb->(GET "/other");
		is($res->header('content-type'), 'text/plain', 'content type not changed');
		is($res->content(), 'Hello, world!', 'response not modified');
	};
}

1;
