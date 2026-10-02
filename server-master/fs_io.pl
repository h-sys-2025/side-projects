#!/usr/bin/perl

use strict;
use warnings;

open my $file, "<", "/etc/passwd" or die "Cannot open data.txt: $!"; # $! contains as operating system error.

while (<$file>) {
  # perl magic, uses $_ as default variable.
  print if m/root/; # => root:x:0:0:root:/root:/bin/bash
  print if $_ =~ m/gAmE/i; # => games:x:5:60:games:/usr/games:/usr/sbin/nologin
}

close $file;

#|
#| open  :: to open a file and return a file descripter.
#| close :: to close (a file descripter).
#|

#|
#| <X> :: read file operator! can read files, sockets and inputs too.
#|

#|
#| <	   :: Read
#| >	   :: Write / overwrite
#| >>	  :: Append
#| +<	  :: Read + write
#|

##### more advances stuff #####################

### reading ##################

open my $file, "<", "/etc/passwd"
    or die "Cannot open: $!";

while (my $line = <$file>) {
    # chomp $line; # removes the last \n.
    print "$line" if $line =~ m/ollama/i;
}

close $file;

### writing ##################

open my $file, ">", "/tmp/output.txt"
    or die "Cannot open: $!";

print $file "Hello Sailor!\n";
print $file "This is a new file.\n";

close $file;

### over writing ################

open my $file, ">>", "log.txt"
    or die "Cannot open: $!";

print $file "logging: Program started\n";

close $file;