#!/usr/bin/perl -w
use strict; 
use warnings;
use File::Find;

# read all the files in the directory specified in @ARGV
# remove numbers in square brackets

find({ wanted => \&process_file, no_chdir => 1 }, @ARGV);

my $indx = 0;
sub process_file {
    if (-f $_) {
		$indx +=1; 
		my $name = $_;
		#rename remove the '_[nnn,;nnnn]_' from names to preserve ordering
		$name =~ s/\_\[\d+\,\;\d+\]\_/\_/;
        print "${indx} This is a file: $name\n";
		rename ($_, $name) or die $!;
    } else {
        print "This is not file: $_\n";
    }
}

