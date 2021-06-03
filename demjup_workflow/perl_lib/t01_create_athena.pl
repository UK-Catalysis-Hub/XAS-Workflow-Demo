#!/usr/bin/perl

use Demeter;
use Class::Inspector;

use perl_lib::DemeterCommon;

sub start_run{
	my $input_file = "fes2_rt01_mar02.xmu";
	my $group_name = "FeS2_xmu";
    my $athena_file = "FeS2_dmtr.prj";
	my $run_auto = "N";
	# if no argument passed, show warning and use defaults
	if (!@ARGV or $#ARGV < 2) {
		print "Need to three argument\n - Input file name\n - Group name";
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
	my $input_data = DemeterCommon::get_data($input_file, $group_name);
	# save the athena project
    DemeterCommon::save_athena($athena_file, $input_data);
}

# run from command line with:
#   perl t01_create_athena.pl data_file(.dat,.txt) group_name demeter_project(.prj)
# for instance:
#   perl  t01_create_athena.pl fes2_rt01_mar02.xmu FeS2_xmu FeS2_dmtr.prj
start_run();