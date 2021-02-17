#!/usr/bin/perl

use Demeter;

sub save_atoms{
	my $crystal_name = shift;

	# open crystal file and run atoms and feff to get the paths
	my $atoms = Demeter::Atoms -> new(file => $crystal_name);
	
	return $atoms
}


my $crystal_file = "FeS2.inp";

#my $feff_data = get_feff($crystal_file);

my $atoms = save_atoms($crystal_file);

print $atoms->Write("feff6");

my $feff_file = "feff_inp.inp";

open my $out, '>:encoding(UTF-8)', $feff_file;

print {$out} $atoms->Write("feff6");

close $out;