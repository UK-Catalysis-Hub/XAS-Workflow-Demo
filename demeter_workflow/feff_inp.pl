#!/usr/bin/perl
use Demeter;

# Call this process to save the result of running atoms
# on a crystal file
sub save_atoms{
	my $crystal_name = shift;
	my $cf_len = length($crystal_name);
	
	
	# open crystal file and run atoms to create 
	# feff input file 
	my $feff_file = lc($crystal_name);
	substr($feff_file, $cf_len-4, 4) = "_feff.inp";
	# create also the dir for feff
	my $feff_dir = $feff_file;
	substr($feff_dir, length($feff_dir)-4, 4) = "";
	
	mkdir($feff_dir, 0700) unless(-d $feff_dir);
	
	my $atoms = Demeter::Atoms -> new(file => $crystal_name);
	open my $out, '>:encoding(UTF-8)', $feff_dir."/".$feff_file;
	print {$out} $atoms->Write("feff6");
	close $out;
}

# Call this process to read parameter 
# and call save atoms with it.
sub run_this{
	# if no argument passed, show warning and use defaults
	my $crystal_file = "FeS2.inp";

	if (!@ARGV) {
		print "Need to provide argument\n";
		print "- Crystal information file\n";
		print "Arguments passed: $#ARGV \n";
	}
	else{
		$crystal_file = $ARGV[0];
		save_atoms($crystal_file);
	}
}

run_this();
