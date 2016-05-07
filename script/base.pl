#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Getopt::Long;
use Try::Tiny;

use lib "lib";
use Api;

my $opts = {};
GetOptions($opts,
    'mode=s',
    'bot=s',
    'token=s',
    'channel=s',
    'text=s',
    'username=s',
    'icon_url=s',
    'file=s',
    'filename=s',
);
try {
    Api::base($opts);
}
catch {
    warn $_;
};

1;
