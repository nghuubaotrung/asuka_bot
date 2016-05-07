#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Try::Tiny;

use lib "lib";
use Api;

try {
    Api::make_slack_map();
}
catch {
    warn $_;
};

1;
