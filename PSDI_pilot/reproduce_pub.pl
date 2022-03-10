#!/usr/bin/perl

# All the tasks can be performed in Demeter, this script shows how to do it.
# 
# The code for each task has been documented in the demeter programing guide
# Example derived from code published at:
#   https://bruceravel.github.io/demeter/documents/DPG

# Publication: 37
# DOI: 10.1039/c7fd00221a
# Data Objects: 
#    43: supplemetary data (.pdf)
#   537: Dataset (including XAS data) 
#   538: Dataset (thesis data, including XAS data) 

use Demeter;
use Class::Inspector;


# open_athena(file_name)
# $file_name parameter should include the complete path relative to the folder
# where this script is stored
sub open_athena{
	my $athena_name =  shift;
	#open athena project 
	my $prj = Demeter::Data::Prj -> new(file=>$athena_name);
	return $prj;
}


# read_athena_groups($file_name, $print)
# $filename: csv file containing the paths, group names and assigned names
# $w_print: indication to print or not during csv reading

sub read_athena_groups{
	my $filename = $_[0];
	my @athena_groups = ();
	my $w_print = 'N';
	if (-e $filename) {
		if ($_[1]){
			$w_print = $_[1];
		}
		
		if ($w_print eq "Y"){
			print "***** Reading athena groups list ******\n";
			print "***** From file $filename ******\n";
		}
		open(FH, '<', $filename) or die $!;
		my @fields = ();
		while(<FH>){
			my $gds_str = $_;
			@fields = split "," , $gds_str;
			push(@athena_groups, [$fields[0],$fields[1],$fields[2]]);
		}
		if ($w_print eq "Y"){
			print "***** Read athena groups list from $filename ******\n";
			print @athena_groups;
		}
		close(FH);
	}
	else{
		print "could not find groups file $filename \n";
	}
	return @athena_groups;
}


# read_athena_groups($file_name, $print)
# $filename: csv file containing the paths, group names and assigned names
# $w_print: indication to print or not during csv reading

sub read_operations{
	my $filename = $_[0];
	my @wf_operations = ();
	my $w_print = 'N';
	if (-e $filename) {
		if ($_[1]){
			$w_print = $_[1];
		}
		
		if ($w_print eq "Y"){
			print "***** Reading operations list ******\n";
			print "***** From file $filename ******\n";
		}
		open(FH, '<', $filename) or die $!;
		my @fields = ();
		while(<FH>){
			my $gds_str = $_;
			@fields = split "," , $gds_str;
		push(@wf_operations, [$fields[0],$fields[1],$fields[2],$fields[3],$fields[4]]);
		}
		if ($w_print eq "Y"){
			print "***** Read $filename ******\n";
			print @wf_operations;
		}
		close(FH);
	}
	else{
		print "could not find operations file $filename \n";
	}
	return @wf_operations;
}


# use the list of athena groups to retrieve data from the athena projects

sub get_athena_data{
	my @data_sources = @{$_[0]};
	my @project_groups = ();
	for my $idx (0 .. $#data_sources) {
		my $athena_file = $data_sources[$idx][0];
		my $athena_group = $data_sources[$idx][1];
		my $group_name = $data_sources[$idx][2];
		print "reading file: ", $athena_file , "\n";
		my $prj_data = open_athena($athena_file);
		print "getting data for group ", $athena_group, "\n";
		my @all_groups = $prj_data  -> allnames;
		for my $gp_idx (0 .. $#all_groups){
			if ($all_groups[$gp_idx ] eq $athena_group){
				my $temp_group = $prj_data-> record($gp_idx+1);
				print "rename the group as: ", $group_name, " \n";
				$temp_group -> set (name => $group_name);
				$temp_group -> bkg_flatten(0);
				$temp_group -> po -> start_plot;
				push(@project_groups, $temp_group );
			}
		}
	}
	return @project_groups;
}

# first operation: plot normalised mu on energy
sub plot_norm_mu_energy{
	my @project_groups =  @{$_[0]};
	my @op_gr =  @{$_[1]};
	my @op_ep =  @{$_[2]};
	my @op_mm =  @{$_[3]}; # plot parameters
	my @eplot = (e_mu   => $op_ep[0], e_bkg    => int($op_ep[1]),
			     e_norm => int($op_ep[2]), e_der    => int($op_ep[3]),
				 e_pre  => int($op_ep[4]), e_post   => int($op_ep[5]),
				 e_i0   => int($op_ep[6]), e_signal => int($op_ep[7]),
				 e_markers => int($op_ep[8])
				 );
	for my $idx (0 .. $#op_gr){
		$project_groups[$op_gr[$idx]] -> po -> set(@eplot);
		$project_groups[$op_gr[$idx]]->xmin($project_groups[$op_gr[$idx]]->bkg_e0-int($op_mm[0]));
		$project_groups[$op_gr[$idx]]->xmax($project_groups[$op_gr[$idx]]->bkg_e0+int($op_mm[1]));
		$project_groups[$op_gr[$idx]]->po->set(emin=>int($op_mm[2]), emax=>int($op_mm[3]));	
		$project_groups[$op_gr[$idx]] -> plot('E');
	}
}

sub do_lcf{
	my @project_groups =  @{$_[0]};
	my @fit_gr =  @{$_[1]}; # fit groups: fit_group, standards 
	my @op_ep =  @{$_[2]}; # plot parameters
	my @op_mm =  @{$_[3]}; # plot parameters
	my @eplot = (e_mu   => $op_ep[0], e_bkg    => int($op_ep[1]),
			     e_norm => int($op_ep[2]), e_der    => int($op_ep[3]),
				 e_pre  => int($op_ep[4]), e_post   => int($op_ep[5]),
				 e_i0   => int($op_ep[6]), e_signal => int($op_ep[7]),
				 e_markers => int($op_ep[8])
				 );
	# the first parameter is the fit group
	my $fit_group = $project_groups[$fit_gr[0]];
	my @std_grps = ();
	my $std_names = "";
	
	# the remaining parameters are the fitting standards
	for my $idx (1 .. $#fit_gr){
		my $a_group = $project_groups[$fit_gr[$idx]];
		push(@std_grps, $a_group);
		$std_names = $std_names . "_" . $a_group -> name;
	}
	my $gr_name = $fit_group -> name;
	my $save_as = 'lcf_fit_' . $gr_name . $std_names .'.dat';
	
	my $lcf = Demeter::LCF -> new(space=>'nor', plot_difference=>0, plot_components=>0);

	$lcf->data($fit_group);
	$lcf->add_many(@std_grps);
	
	$lcf->xmin($fit_group->bkg_e0-int($op_mm[0]));
	$lcf->xmax($fit_group->bkg_e0+int($op_mm[1]));
	$lcf->po->set(emin=>int($op_mm[2]), emax=>int($op_mm[3]));
	
	$lcf -> fit -> plot -> save($save_as);
	
	#$lcf->po->set(@eplot);

    print $lcf->report;

	$lcf -> plot_fit;	
}

# required data for figure 4 A, B, C
# Athena File                  Data group                        Name
# Sn foil.prj                  merge                             Sn Foil
# SnO2 0.9 2.6-13.5 gbkg.prj   SnO2 0.9                          SnO2
# PtSn_OC.prj                  PtSn_OC_MERGE_CALIBRATE rebinned  PtSn
# PtSn_OCA.prj                 PtSn_OCA rebinned                 Ar
# PtSn_OCH.prj                 PtSn_OCH rebinned                 H2 
# PtSn_OCO.prj                 PtSn_OCO rebinned                 air 
# PtSn_OCH_H2.prj              PtSn_OCH rebinned                 H2-H2



# 1. Read data from athena project files (file, group, name)
# @data_sources = (['..\psdi_data\pub_037\XAFS_prj\SnO2 0.9 2.6-13.5 gbkg.prj', 'SnO2 0.9', 'SnO2'],
				     # ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCO.prj', 'PtSn_OCO rebinned', 'air'],
					 # ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCA.prj', 'PtSn_OCA rebinned', 'Ar'],
					 # ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCH.prj', 'PtSn_OCH rebinned', 'H2'],
					 # ['..\psdi_data\pub_037\XAFS_prj\Sn foil.prj', 'merge', 'Sn Foil'],
					 # ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OC.prj', 'PtSn_OC_MERGE_CALIBRATE rebinned',  'PtSn'],
					 # ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCH_H2.prj', 'PtSn_OCH rebinned', 'H2-H2']); 					 
my @data_sources = read_athena_groups("pub_037_athena.csv", "N");

# intermediate: set parameters for plot object
my @eplot = (e_mu => 1, e_bkg  => 0,
			 e_norm    => 1,     e_der     => 0,
			 e_pre     => 0,     e_post    => 0,
			 e_i0      => 0,     e_signal  => 0,
			 e_markers => 0
			);

# 2. read data from athena projects
my @project_groups = get_athena_data(\@data_sources);

# read the list of operations to be performed on the data objects
my @operations = read_operations("pub_037_operations.csv", "N");

for my $op_idx (0 .. $#operations){
	my $op_id = $operations[$op_idx][0];
	# groups used in the operation
	my @op_gr = split /\|/, $operations[$op_idx][1];
	
	# plotting parameters for the operation
	my @op_ep = split /\|/,  $operations[$op_idx][2];
	
	# graph min-max
	my @op_mm = split /\|/,  $operations[$op_idx][4];
	
	# display text for the operation
	my $op_msg = $operations[$op_idx][3];
	print $op_msg, "\n";
	if ($op_id == 1 or $op_id == 2){
		# operations 1 and 2 are the same only the plotting parameters change
		plot_norm_mu_energy(\@project_groups, \@op_gr, \@op_ep, \@op_mm);
	}
	if ($op_id == 3){
		# operation 3 is the lineal combination fitting
		do_lcf(\@project_groups, \@op_gr, \@op_ep, \@op_mm);
	}
	# reset plot after each operation
	$project_groups[0] -> po -> start_plot;
	print "Press any key to continue\n";
	<STDIN>;
}
