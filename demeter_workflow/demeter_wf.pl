#!/usr/bin/perl

# All the tasks of the basic workflow can be performed in Demeter,
# this script shows how to do it.
# 
# The code for each task has been documented in the demeter programing guide
# Example derived from code published at:
#   https://bruceravel.github.io/demeter/documents/DPG

# First example of importing a Mu(e) data file and plotting it

use Demeter;
use Class::Inspector;
# 1.1. Import data         |File: fes2_rt01_mar02.xmu            | 
# 1.2. Normalisation       |Parameters:                          |
#                          |  Pre-edge range = -117.00 to 30.000 |
# 1.3. Save Athena Project |                                     |FeS2_dmtr.prj

sub get_data{
	my $file_name = shift;
	my $group_name = shift;
	my $data = Demeter::Data -> new(file => $file_name,
									name => $group_name,
								);
	return $data
}

sub save_athena{
	my $file_name = shift;
	my $data = shift;
	# Save as athena project
	# from https://github.com/bruceravel/demeter/blob/411cf8d2b28819bd7a21a29869c7ad0dce79a8ac/documentation/DPG/output.rst
	$data->write_athena($file_name, $data);
}

sub start{
	my $input_file = "fes2_rt01_mar02.xmu";
	my $group_name = "FeS2_xmu";
    my $athena_file = "FeS2_dmtr.prj";
	# if no argument passed, show warning and use defaults
	
	if (!@ARGV or $#ARGV < 2) {
		print "Need two provide three argument\n - Input file name\n - Group name";
		print "\n - Athena file name\n";
		print "Arguments passed: $#ARGV + 1";
	}
	else{
		my $test_argument = $ARGV[0];
		if (-e $test_argument) {
			print "Reading from file: $test_argument\n";
			$input_file = $test_argument;
			}
		else{
			print "Input file does not exist: $test_argument\n";
			print "Reading from default file: $input_file\n";
		}
		$group_name = $ARGV[1];
		$athena_file = $ARGV[2];
		print "Group Name: $group_name\n";
	}
	
	my $input_data = get_data($input_file, $group_name);
	$input_data -> plot('E');
	print $input_data -> data_parameter_report;

	# set parameters for normalisation and background removal
	$input_data -> set(bkg_rbkg    => 1.5,
             bkg_spl1    => 0,    bkg_spl2    => 18,
             bkg_nor1    => 100,  bkg_nor2    => 1800,
			 bkg_pre1    => -117, bkg_pre2	 => -30, 
             fft_kmax    => 3,    fft_kmin    => 17,
            );
	$input_data -> plot('E');
	sleep 5;
	print ($input_data->Athena->pre_edge_range);
	# Save as athena project
	# from https://github.com/bruceravel/demeter/blob/411cf8d2b28819bd7a21a29869c7ad0dce79a8ac/documentation/DPG/output.rst
	save_athena($athena_file, $input_data);
	my $prj = Demeter::Data::Prj -> new(file=>$athena_file);
	print "*** Athena Project ***\n";
	print $prj -> list;
}
start;