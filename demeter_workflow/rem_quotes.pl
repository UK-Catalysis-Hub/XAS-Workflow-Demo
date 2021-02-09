#!/usr/bin/perl
use utf8;
my $st = "“Quotes1” «Quotes2» ‘Quotes3’ 'Quotes4' \"Quotes5\"";
print "Before: $st\n";
$st =~ s/[\p{Pi}\p{Pf}'"]//g;
print "After: $st\n";