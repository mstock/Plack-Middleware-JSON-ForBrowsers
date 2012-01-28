package Plack::Middleware::JSON::ForBrowsers;
use base qw(Plack::Middleware);

# ABSTRACT: Plack middleware which turns application/json responses into HTML

use strict;
use warnings;
use Carp;
use JSON;
use MRO::Compat;
use Plack::Util::Accessor qw(json);
use List::MoreUtils qw(any);

=head1 SYNOPSIS

	use Plack::Builder;

	builder {
		enable 'JSON::ForBrowsers';
		$app;
	};

=head1 DESCRIPTION

Plack::Middleware::JSON::ForBrowsers does turn C<application/json> responses
into HTML that can be displayed in the web browser. This is primarily intended
as a development tool, especially for use with
L<Plack::Middleware::Debug|Plack::Middleware::Debug>.

The middleware checks the request for the C<X-Requested-With> header - if it
does not exist or its value is not C<XMLHttpRequest>, it will wrap the JSON from
a C<application/json> response with HTML and adapt the content type accordingly.

=cut

chomp(my $html_head = <<'EOHTML');
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>JSON::ForBrowsers</title>
		<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
		<style type="text/css">
			html, body {
				padding: 0px;
				margin: 0px;
			}
			pre {
				background-color: #FAFAFA;
				border: 1px solid #E9E9E9;
				padding: 4px;
				margin: 12px;
			}
		</style>
	</head>
	<body>
		<pre><code>
EOHTML

(my $html_foot = <<'EOHTML') =~ s/^\s+//x;
		</code></pre>
	</body>
</html>
EOHTML

my @json_types = qw(application/json);

=method new

Constructor, creates new instance.

=cut

sub new {
	my ($class, $arg_ref) = @_;

	my $self = $class->next::method($arg_ref);
	$self->json(JSON->new()->utf8()->pretty());

	return $self;
}

=method call

Specialized C<call> method.

=cut

sub call {
	my($self, $env) = @_;

	my $res = $self->app->($env);

	# Don't wrap response to Ajax call
	unless ($self->looks_like_browser_request($env)) {
		return $res
	}

	return $self->response_cb($res, sub {
		my ($cb_res) = @_;

		my $h = Plack::Util::headers($cb_res->[1]);
		# Ignore stuff like '; charset=utf-8' for now
		if (any { index($h->get('Content-Type'), $_) >= 0 } @json_types) {
			$h->set('Content-Type' => 'text/html; charset=utf-8');

			my $json = '';
			my $seen_last = 0;
			return sub {
				if (defined $_[0]) {
					$json .= $_[0];
					return '';
				}
				else {
					if ($seen_last) {
						return;
					}
					else {
						$seen_last = 1;
						my $pretty_json = $self->json()->encode(
							$self->json()->decode($json)
						);
						return $html_head.$pretty_json.$html_foot;
					}
				}
			};
		}
		return;
	});
}


=method looks_like_browser_request

Try to decide if a request is coming from a browser. Uses the C<Accept> and
C<X-Requested-With> headers for this decision.

=head3 Parameters

This method expects positional parameters.

=over

=item env

The L<Plack> environment.

=back

=head3 Result

C<1> if it looks like the request came from a browser, C<0> otherwise.

=cut

sub looks_like_browser_request {
	my ($self, $env) = @_;

	if (defined $env->{HTTP_X_REQUESTED_WITH}
			&& $env->{HTTP_X_REQUESTED_WITH} eq 'XMLHttpRequest') {
		return 0;
	}

	if (defined $env->{HTTP_ACCEPT}
			&& any { index($env->{HTTP_ACCEPT}, $_) >= 0 } qw(text/html application/xhtml+xml)) {
		return 1;
	}

	return 0;
}

1;

