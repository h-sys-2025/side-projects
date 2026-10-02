#!/usr/bin/perl

use warnings;
use strict;

my $name = "hamza";

print "$name\n";

# command line args ######################

my ($x, $y) = @ARGV;

# conditionals #######################

if (!$x) {
  die "command line argument 1 is required!"
}

print "$x\n";
print "$y\n" if $y; # nice!

# loops and arrays #########################

my @nums = (1..10);

for my $num (@nums) {
  print "($num * $num) is equal to (".$num*$num.")\n";
}

my @people = ("Hamza", "Bob", "Alice", "Loream", "Epsum", "Lor", "Si", "Amet");

print "@people\n";    # => Hamza Bob Alice Loream Epsum Lor Si Amet
print "$people[2]\n"; # => Alice

push @people, "Trevor"; # now last element is "Trevor".

print "last index of array: $#people\n";
print "element at index $#people: $people[$#people]\n";

my $trevor = pop @people;

unshift @people, "Adam";
print "adam is first element in people list: $people[0]\n";
my $adam = shift @people;

#|
#| - THE HOLY GRAIL OF ARRAY MANAGEMENT!
#|
#| shift    :: remove from beggining (and return).
#| unshift  :: add to beggining.
#| push     :: add to last.
#| pop      :: remove from last (and return).
#|


for my $person (@people) {
  print "$person\n";
  # Hamza
  # Bob
  # Alice
  # Loream
  # Epsum
  # Lor
  # Si
  # Amet
}

#|
#| $#people (means, the index of last element of that array, can be used to get the lenght of an array)
#|

for my $i (0 .. $#people/2) {
  print "$i) $people[$i]\n";
}

# hashes ##########################

my %config = (
  port => "8080",
  default_user => "user_admin",
  default_pass => "ChangeMe!1234",
  secret => "h&^TG&^T76Rgry(T&TGg&^r8g&R^8F%"
); # this is hash, we can make hash refrence using '{...}'

my $default_host = "localhost";
my $default_port = $config{port};

my $connection_string = $default_host . ":" . $default_port;

print "$connection_string\n";
print "reading config for secret, secret is $config{secret}\n";

print "$config{default_pass}\n";

$config{secret} = "removed secret, haha!";
print "$config{secret}\n";

delete $config{secret};

if (!exists $config{secret}) {
  print "secret deleted successfully!\n";
} else {
  die "alert!!! secret is still in memory!\n";
}

#|
#| - SOME BUILTIN FUNCTIONS FOR HASHES!
#|
#| exists  :: to check if something exists! | exists $config{secret};
#| delete  :: to delete an existing item!   | delete $config{secret};
#| keys    :: to get all keys!              | keys $config;
#| values  :: to get all values!            | values $config;
#|

print "keys in my config:\n";
for my $key (keys %config) {
  print " - $key\n";
}

for my $value (values %config) {
  print "value is: $value\n" if $value !~ m/admin/i; # `m` is for match then word inside /.../ and `i` is for case-insentivitive.
  # dont print anything with "admin" in it, case-insensitivive.
}

my %person = (
  name    => "Hamza",
  hobbies => ["A", "B", "C"]
);

print "hobby 3 is: $person{hobbies}[2]\n";

my @my_hobbies = @{$person{hobbies}}; # de-structureing a hash!

@my_hobbies = $person{hobbies}->@*; # this is also possible (de-structureing a hash).

for my $hobby (@my_hobbies) {
  print "-> $hobby\n";
}

# advances hashes and arrays #############################

my @database = (
  { name => "Hamza", age => 17 },
  { name => "Ali",   age => 20 },
  { name => "Ahmed", age => 25 }
);

for my $i (0..$#database) {
  print "data record entry #$i: person: $database[$i]{name} with age: $database[$i]{age}\n";
}

