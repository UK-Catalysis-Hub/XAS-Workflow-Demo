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

sub clear_screen{
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
}

sub show_graphs{
	my $data = shift;
	my $option = 0;
	clear_screen;
	print "Show graphs\n";
	while ($option != 7){
		clear_screen;
		show_parameters($data);
		print "Options:\n";
		print "1) Quad\n";
		print "2) E \n";
		print "3) E Normalised \n";
		print "4) Flattened data and background\n";
		print "5) k 123\n";
		print "6) Magnitude in R-space & R-space window\n";
		print "7) return\n";
		print "Your selection (1-3): ";
		$option = <STDIN>;
		if ($option == 1) {
			print "Show Quad";
			$data -> po -> start_plot;
			$data -> plot('quad');
		}
		elsif ($option  == 2) {
			print "Show E plot";
			my @eplot = (e_mu      => 1,     e_bkg     => 1,
             e_norm    => 0,     e_der     => 0,
             e_pre     => 1,     e_post    => 1,
             e_i0      => 0,     e_signal  => 0,
             e_markers => 1,
             space     => 'E',
            );
			$data -> po -> set(@eplot);
			$data -> po -> start_plot;
			$data -> plot;
		}
		elsif ($option  == 3) {
			print "Show E Normalised plot";
			my @eplot = (e_mu      => 1,     e_bkg     => 1,
             e_norm    => 1,     e_der     => 0,
             e_pre     => 0,     e_post    => 0,
             e_i0      => 0,     e_signal  => 0,
             e_markers => 1,
             space     => 'E',
            );
			$data -> po -> set(@eplot);
			$data -> bkg_flatten(0);
			$data -> po -> start_plot;
			$data -> plot;
		}
		elsif ($option  == 4) {
			print "Flattened data & background";
			my @eplot = (e_mu      => 1,     e_bkg     => 1,
             e_norm    => 1,     e_der     => 0,
             e_pre     => 0,     e_post    => 0,
             e_i0      => 0,     e_signal  => 0,
             e_markers => 1,
             space     => 'E',
            );
			$data -> po -> set(@eplot);
			$data -> bkg_flatten(1);
			$data -> po -> start_plot;
			$data -> plot;
		}
		elsif ($option  == 5) {
			print "Show k 123 plot";
			$data -> po -> start_plot;
			$data -> plot('k123');
		}
		elsif ($option == 6) {
			print "Show R";
			$data -> po -> set(kweight => 2, r_pl => 'm', space => 'r', );
			$data -> po -> start_plot;
			$data -> plot -> plot_window;
		}		
		elsif ($option == 7) {
			print "Return";
		}
		else {
			print "invalid selection\n";
		}
	}
}

sub show_parameters{
	clear_screen;
	my $data = shift;
	print "Show parameters\n";
	print $data -> data_parameter_report;
}

sub set_parameters{
	clear_screen;
	print "Set parameters\n";
}

sub save_and_exit{
	clear_screen;
	print "Save Athena project and exit\n";
}

sub select_task{
	my $data = shift;
	my $option = 0;
	while ($option != 4){
		clear_screen;
		print "Options:\n";
		print "1) show graph\n";
		print "2) show parameters\n";
		print "3) set parameters\n";
		print "4) save athena project and exit\n";
		print "Your selection (1/2/3/4): ";
		$option = <STDIN>;
		if ($option == 1) {
			show_graphs($data);
		}
		elsif ($option  == 2) {
			show_parameters($data);
		}
		elsif ($option == 3) {
			set_parameters($data);
		}
		elsif ($option == 4) {
			save_and_exit;
		}
		else {
			print "invalid selection\n";
		}
	}
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
	# 1.1. Import data         |File: fes2_rt01_mar02.xmu            | 

	my $input_data = get_data($input_file, $group_name);
	
	print $input_data -> data_parameter_report;

	# 1.2. Normalisation       |Parameters:                          |
	#                          |  Pre-edge range = -117.00 to 30.000 |
	# set parameters for normalisation and background removal
	# get parameter names from:
	#    https://github.com/bruceravel/demeter/blob/411cf8d2b28819bd7a21a29869c7ad0dce79a8ac/attic/doc/misc/json_project.org
	# as with the basic workflow, only pre-edge limits are modified
	$input_data -> set(bkg_pre1    => -117, bkg_pre2	 => -30);
    # 1.3. Save Athena Project |                                     |FeS2_dmtr.prj
	# from https://github.com/bruceravel/demeter/blob/411cf8d2b28819bd7a21a29869c7ad0dce79a8ac/documentation/DPG/output.rst
	save_athena($athena_file, $input_data);
	my $prj = Demeter::Data::Prj -> new(file=>$athena_file);
	#print "*** Athena Project ***\n";
	#print $prj -> list;
	select_task($input_data);
}

start;