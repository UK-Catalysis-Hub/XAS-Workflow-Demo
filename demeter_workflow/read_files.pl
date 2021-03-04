#!/usr/bin/perl -w
use strict; 
use warnings;
use File::Find;

# read all the files in the directory specified in @ARGV

find({ wanted => \&process_file, no_chdir => 1 }, @ARGV);

my $indx = 0;
sub process_file {
    if (-f $_) {
		$indx +=1; 
		my $name = $_;
        print "${indx} This is a file: $name\n";		
    } else {
        print "This is not file: $_\n";
    }
}