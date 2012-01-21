#!/usr/bin/env plackup

use strict;
use warnings;

use Plack::Builder;

my $json_app = sub { return [
	200,
	[ 'Content-Type' => 'application/json' ],
	[ '{"foo":"bar"}' ]
] };

my $other_app = sub { return [
	200,
	[ 'Content-Type' => 'text/plain' ],
	[ 'Hello, world!' ]
] };

my $app = builder {
	enable 'JSON::ForBrowsers';
	mount '/json'  => $json_app;
	mount '/other' => $other_app;
};
