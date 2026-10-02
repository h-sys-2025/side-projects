#!/usr/bin/perl

use strict;
use warnings;

if (-e "/etc/passwd") {
    print "File '/etc/passwd': File exists!\n";
}

#| -e $path   # exists
#| -f $path   # regular file
#| -d $path   # directory
#| -r $path   # readable
#| -w $path   # writable
#| -x $path   # executable
#| -s $path   # size

my $file = "/etc/passwd";

if (-f $file && -r $file) {
    print "File '/etc/passwd': Readable file!\n";
}

if (-d "/etc/") {
    print "Directory '/etc/': directory exists!\n";
}

## dir things ##

opendir my $dir, "."
    or die "Cannot open directory: $!";


print "files inside '.' dir:\n";

while (my $entry = readdir $dir) {
    next if $entry eq "." || $entry eq "..";

    print " - $entry\n";
}

closedir $dir;