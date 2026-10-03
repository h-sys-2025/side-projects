#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;

# downlaod using this cmd: cpan LWP::UserAgent

my $client = LWP::UserAgent->new();

my $resp = $clieny->get("https://example.com");

print $resp->status_line."\n";
print $resp->decoded_content."\n";