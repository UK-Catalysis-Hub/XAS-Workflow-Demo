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

sub open_athena{
	my $athena_name =  shift;
	#open athena project 
	my $prj = Demeter::Data::Prj -> new(file=>$athena_name);
	return $prj;
}

sub clear_screen{
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
}

sub wait_for_key() {
	my $any_key = "";
    print "\nPress any key to continue...";
    chomp($any_key = <STDIN>);
}

sub show_groups{
	my $prj_file = shift;
	# print a list of the groups in the project file
	print $prj_file -> list;
}

sub show_selected_groups{
	my $prj_file = $_[0];
	my @group_list = @{$_[1]};
	my @all_groups = $prj_file  -> allnames;
	my $groups_len = scalar @all_groups;
	# print a list of the groups in the project file
	print "\t Select \t Record\n";
	for my $i (0 .. $#all_groups) {
		my $indx = $i+1;
		if ($indx ~~ @group_list){
			print "\t    X     $indx : $all_groups[$i] \n";
		}
		else{
			print "\t          $indx : $all_groups[$i] \n";
		}
	}
}

sub change_group{
	my $prj_file = shift;
	my $current_group = shift;
	my $group_name = $current_group -> name;
	my @groups_list = $prj_file  -> allnames;
	# print a list of the groups in the project file
	my $groups_len = scalar @groups_list;
	print "Size: ",$groups_len,"\n";
	my $option = 0;
	while ($option != $groups_len+1){
		print "Selected group: $group_name \n";
		show_groups($prj_file);
		print "\t ", @groups_list+1, ": Return \n";
		print "Your selection (1-", @groups_list+1,"): ";
		$option = <STDIN>;
		if ($option > 0 and $option <= $groups_len)
		{
			$current_group =  $prj_file -> record($option);
			$group_name = $current_group -> name;
		}		
	}
	return $current_group;
}

sub show_parameters{
	my $data = shift;
	print "Data parameters\n";
	print $data -> data_parameter_report;
}

sub show_graphs{
	my $prj_file = shift;
	my $sel_group = shift;
	my @all = $prj_file -> slurp;
    $_ -> plot('E') foreach @all;
	
	show_graph ($prj_file -> record(1));
	show_graph ($sel_group);
}

sub show_graph{
	my $data = shift;
	my $option = 0;
	print "Show graphs\n";
	while ($option != 7){
		clear_screen;
		show_parameters($data);
		print "************************************************************\n";
		print "Options:\n";
		print "1) Quad\n";
		print "2) E \n";
		print "3) E Normalised \n";
		print "4) Flattened data and background\n";
		print "5) k 123\n";
		print "6) Magnitude in R-space & R-space window\n";
		print "7) return\n";
		print "Your selection (1-7): ";
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
		else {
			print "invalid selection\n";
		}
	}
}

sub single_group{
	my $prj_file = shift;
	my $selected_group =  $prj_file -> record(1);
	my $group_name = $selected_group -> name;
	my @group_list = ();
	
	my $option = 0;
	while ($option != 4){
		clear_screen;
		show_groups($prj_file);
		print "Selected group: $group_name \n";
		print "*************************************************************\n";
		print "Options:\n";
		print "1) show graph\n";
		print "2) view parameters\n";
		print "3) change group\n";
		print "4) return\n";
		print "Your selection (1-4): ";
		$option = <STDIN>;
		if ($option == 1){
			#show_graphs($prj_file, $selected_group);
			show_graph ($selected_group);
		}
		elsif ($option  == 2){
			show_parameters($selected_group);
			wait_for_key;
		}
		elsif ($option  == 3){
			$selected_group = change_group($prj_file, $selected_group);
			$group_name = $selected_group -> name;
		}
		elsif ($option  == 4){
			@group_list = make_list($prj_file, @group_list);
		}
		elsif ($option == 4){
			print "Return to main\n";
		}
		else {
			print "invalid selection\n";
		}
	}
}

sub show_graphs{
	my $prj_file = $_[0];
	my @group_list = @{$_[1]};
	my $groups_len = scalar @group_list;
	my $option =0;
	$groups_len = scalar($prj_file  -> allnames);
	while ($option != 5){
		# need to print selected paths
		print "************************************************************\n";
		show_selected_groups($prj_file, \@group_list);
		print "************************************************************\n";
		print "Show graph:\n";
		print "1) E Normalised \n";
		print "2) k\n";
		print "3) R\n";
		print "4) q\n";
		print "5) Return\n";
		print "Your selection (1-5): ";
		$option = <STDIN>;
		if ($option > 0 and $option <= 4)
		{ 
			my $data = 1;
			my @several = ();
			for my $i (0 .. $groups_len) {
				my $indx = $i+1;
				if ($indx ~~ @group_list){
					$data = $prj_file -> record($indx);
					my @eplot = (e_mu => 1, e_bkg  => 0,
					e_norm    => 1,     e_der     => 0,
					e_pre     => 0,     e_post    => 0,
					e_i0      => 0,     e_signal  => 0,
					e_markers => 1
					);
					$data -> po -> set(@eplot);
					$data -> bkg_flatten(0);
					$data -> po -> start_plot;
					push (@several, $data);
				}
			}
			if ($option == 1) {
				print "Show E plot for groups", @group_list, "\n";
				$_ -> plot('E') foreach @several;
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
		}
		elsif ($option == 5){
			print "Return\n";
		}
		else{
			print "invalid option";
		}
	}
	
}

sub make_list{
	my $prj_file = $_[0];
	my @group_list = @{$_[1]};
	my $groups_len = scalar @group_list;
	#if ($groups_len == 0){
	#	@group_list = (1, 3, 5, 7)
	#}
	my $option =0;
	$groups_len = scalar($prj_file  -> allnames);
	while ($option != $groups_len+1){
		# need to print selected paths
		print "Select groups\n";
		print "\tTo mark or unmark a group, just enter the id.\n";
		print "\teach time the group marking switches, this is,\n";
		print "\tif marked it is unmarked, if unmarked then it \n";
		print "\tis marked\n";
		print "Options:\n";
		print "************************************************************\n";
		show_selected_groups($prj_file, \@group_list);
		print "\t\t ", $groups_len+1 , ": Return \n";
		print "Your selection (1-", $groups_len+1 ,"): ";
		$option = <STDIN>;
		if ($option > 0 and $option <= $groups_len)
		{
			if ($option ~~ @group_list){
				print "remove from list: ", $option;
				my $remove = -1;
				for my $i (0 .. $#group_list) {
					if ($group_list[$i] == $option){
						$remove = $i;
					}					
				}
				if ($remove != -1){
					splice(@group_list, $remove,1);
				}
			}
			else{
				print "add to list: ", $option ;
				push(@group_list, $option);
			}
		}
		elsif ($option == $groups_len+1){
			print "Return\n";
		}
		else{
			print "invalid option";
		}
	}
	return @group_list;
}

sub group_list{
	my $prj_file = shift;
	my @group_list = ();
	
	my $option = 0;
	while ($option != 3){
		clear_screen;
		show_selected_groups($prj_file, \@group_list);
		print "*************************************************************\n";
		print "Options:\n";
		print "1) show graph\n";
		print "2) select groups\n";
		print "3) return\n";
		print "Your selection (1-3): ";
		$option = <STDIN>;
		if ($option == 1){
			show_graphs ($prj_file, \@group_list);
		}
		elsif ($option  == 2){
			@group_list = make_list($prj_file, \@group_list);
		}
		elsif ($option == 3){
			print "Return to main\n";
		}
		else {
			print "invalid selection\n";
		}
	}
}

sub select_task{
	my $prj_file = shift;
	my $option = 0;
	while ($option != 3){
		clear_screen;
		print "*************************************************************\n";
		print "Options:\n";
		print "1) single group\n";
		print "2) group list\n";
		print "3) exit\n";
		print "Your selection (1-3): ";
		$option = <STDIN>;
		if ($option == 1){
			single_group($prj_file);
		}
		elsif ($option  == 2){
			group_list($prj_file);
		}
		elsif ($option  == 3){
			print "End session\n";
		}
		else {
			print "invalid selection\n";
		}
	}
}


sub start{
    my $athena_file = "FeS2_dmtr.prj";
	my $num_args = $#ARGV + 1;
	
	# if no argument passed, show warning and use defaults
	if ($num_args < 1) {
		print "Need to provide argument\n";
		print "\n - Athena file name\n";
		print "Arguments passed: $num_args";
	}
	else{
		$athena_file = $ARGV[0];
	}
	# open input file and get data
    my $prj_data = open_athena($athena_file);
	# print parameters and present options
	select_task($prj_data);
}
# Run from the command line as:
# perl explore_athena.pl "psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OC.prj"
start();