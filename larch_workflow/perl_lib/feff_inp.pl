#!/usr/bin/perl
use Demeter;

# Call this process to save the result of running atoms
# on a crystal file.
# Parameters: 
#  - name of the crystal file
#  - name of the feff dir for processing
#  - name of the feff input file
sub save_atoms{
	my $crystal_name = shift;
	my $feff_dir = shift; 
	my $feff_file = shift;
	my $cf_len = length($crystal_name);
	mkdir($feff_dir, 0700) unless(-d $feff_dir);
	
	my $atoms = Demeter::Atoms -> new();
	if (substr($crystal_name, -3,3 ) eq "cif"){
		$atoms->cif($crystal_name);
	}
	else
	{
		$atoms->file($crystal_name);
	}
    
	open my $out, '>:encoding(UTF-8)', $feff_dir."/".$feff_file;
	print {$out} $atoms->Write("feff6");
	close $out;
}

# Call this process to read parameter 
# and call save atoms with it.
sub run_this{
	# if no argument passed, show warning and use defaults
	my $crystal_file = "FeS2.inp";
	my $feff_wd = "FeS2_calc";
	my $feff_if = "FeS2_feff.inp";
    
	if (!@ARGV or @ARGV < 2) {
		my $arg_count = scalar @ARGV;
		print "Need to provide 3 arguments \n";
		print "- Crystal information file\n";
		print "- Path to store feff calculations\n";
		print "- name of feff input file\n";
		print "Arguments passed: $arg_count\n";
	}
	else{
		$crystal_file = $ARGV[0];
		$feff_wd = $ARGV[1];
		$feff_if = $ARGV[2];        
		save_atoms($crystal_file, $feff_wd, $feff_if);
	}
}

run_this();
