#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Getopt::Long;
use Try::Tiny;

use lib "lib";
use Api;
use Client;

my $opts = {};
GetOptions($opts,
    'token=s',
);

#opts must have token
die "no token" unless $opts->{token};

try {
    my $socket_url = Api::get_rtm_socket($opts->{token});
    Client::connect($socket_url, $opts->{token});
}
catch {
    warn $_;
};

1;
