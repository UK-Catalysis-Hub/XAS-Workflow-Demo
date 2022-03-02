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

sub open_athena{
	my $athena_name =  shift;
	#open athena project 
	my $prj = Demeter::Data::Prj -> new(file=>$athena_name);
	return $prj;
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
my @data_sources = (['..\psdi_data\pub_037\XAFS_prj\SnO2 0.9 2.6-13.5 gbkg.prj', 'SnO2 0.9', 'SnO2'],
				     ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCO.prj', 'PtSn_OCO rebinned', 'air'],
					 ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCA.prj', 'PtSn_OCA rebinned', 'Ar'],
					 ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCH.prj', 'PtSn_OCH rebinned', 'H2'],
					 ['..\psdi_data\pub_037\XAFS_prj\Sn foil.prj', 'merge', 'Sn Foil'],
					 ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OC.prj', 'PtSn_OC_MERGE_CALIBRATE rebinned',  'PtSn'],
					 ['..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCH_H2.prj', 'PtSn_OCH rebinned', 'H2-H2']); 

# intermediate: set parameters for plot object
my @eplot = (e_mu => 1, e_bkg  => 0,
			 e_norm    => 1,     e_der     => 0,
			 e_pre     => 0,     e_post    => 0,
			 e_i0      => 0,     e_signal  => 0,
			 e_markers => 0
			);

# 2. read data from athena projects
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
			$temp_group -> po -> set(@eplot);
			$temp_group -> bkg_flatten(0);
			$temp_group -> po -> start_plot;
			push(@project_groups, $temp_group );
		}
	}
}
# 3. plot first five on E normalised for Figure 4A 
print "Show normalised E plot for first five groups\n";
for my $idx (0 .. 4){
	$project_groups[$idx] -> plot('E');
}
my $option = <STDIN>;

#reset plot object
@eplot = (e_mu => 1, e_bkg  => 0,
		  e_norm    => 1,     e_der     => 1,
		  e_pre     => 0,     e_post    => 0,
		  e_i0      => 0,     e_signal  => 0,
		  e_markers => 0
		);
$project_groups[0] -> po -> start_plot;
# 4. plot first derivate for first five groups for Figure 4A inset

for my $idx (0 .. 4){
	$project_groups[$idx] -> po -> set(@eplot);
	$project_groups[$idx] -> plot('E');
}

$option = <STDIN>;


# 5. LCF for H2, Ar, Air 
my $lcf = Demeter::LCF -> new(space=>'nor', plot_difference=>0, plot_components=>0);

# fit groups: H2 (3), Ar (2), Air (1)
# standards: SnO2 (0), Sn Foil (4)

# fit H2
my $fit_group = $project_groups[3];
my ($foil, $oxide, $h2h2) = ($project_groups[0],$project_groups[4], $project_groups[6] );

$lcf->data($fit_group);
$lcf->add_many($foil, $oxide);


$lcf->xmin($fit_group->bkg_e0-20);
$lcf->xmax($fit_group->bkg_e0+60);
$lcf->po->set(emin=>-30, emax=>80);

$lcf -> fit -> plot -> save('lcf_fit_H2_1.dat');

$lcf -> pause;

$lcf->clean;

$lcf->po->start_plot;
$lcf->po->set(e_norm=>0, e_der=>1);
$lcf -> plot_fit;

print "Showing SnO2 and Sn foil fit for H2\n";
print $lcf->report;
$option = <STDIN>;

# fit Ar
$fit_group = $project_groups[2];

$lcf->data($fit_group);


$lcf->xmin($fit_group->bkg_e0-20);
$lcf->xmax($fit_group->bkg_e0+60);
$lcf->po->set(emin=>-30, emax=>80);

$lcf -> fit -> plot -> save('lcf_fit_Ar_1.dat');


$lcf -> pause;

$lcf->clean;

$lcf->po->start_plot;
$lcf->po->set(e_norm=>0, e_der=>1);
$lcf -> plot_fit;

print "Showing SnO2 and Sn foil fit for Ar\n";
print $lcf->report;

$option = <STDIN>;

# fit Air
my $fit_group = $project_groups[1];

$lcf->data($fit_group);


$lcf->xmin($fit_group->bkg_e0-20);
$lcf->xmax($fit_group->bkg_e0+60);
$lcf->po->set(emin=>-30, emax=>80);

$lcf -> fit -> plot -> save('lcf_fit_Air_1.dat');

$lcf -> pause;

$lcf->clean;

$lcf->po->start_plot;
$lcf->po->set(e_norm=>0, e_der=>1);
$lcf -> plot_fit;

print "Showing SnO2 and Sn foil fit for Air\n";
print $lcf->report;
$option = <STDIN>;

$lcf = Demeter::LCF -> new(space=>'nor', plot_difference=>0, plot_components=>0);

$lcf->data($fit_group);
$lcf->add_many($foil, $h2h2);


$lcf->xmin($fit_group->bkg_e0-20);
$lcf->xmax($fit_group->bkg_e0+60);
$lcf->po->set(emin=>-30, emax=>80);

$lcf -> fit -> plot -> save('lcf_fit_H2_2.dat');

$lcf -> pause;

$lcf->clean;

$lcf->po->start_plot;
$lcf->po->set(e_norm=>0, e_der=>1);
$lcf -> plot_fit;

print "Showing SnO2 and H2-H2 fit for H2\n";
print $lcf->report;
$option = <STDIN>;


# fit Ar
$fit_group = $project_groups[2];

$lcf->data($fit_group);


$lcf->xmin($fit_group->bkg_e0-20);
$lcf->xmax($fit_group->bkg_e0+60);
$lcf->po->set(emin=>-30, emax=>80);

$lcf -> fit -> plot -> save('lcf_fit_Ar_2.dat');

$lcf -> pause;

$lcf->clean;

$lcf->po->start_plot;
$lcf->po->set(e_norm=>0, e_der=>1);
$lcf -> plot_fit;

print "Showing SnO2 and H2-H2 fit for Ar\n";
print $lcf->report;
$option = <STDIN>;

# fit Air
my $fit_group = $project_groups[1];

$lcf->data($fit_group);


$lcf->xmin($fit_group->bkg_e0-20);
$lcf->xmax($fit_group->bkg_e0+60);
$lcf->po->set(emin=>-30, emax=>80);

$lcf -> fit -> plot -> save('lcf_fit_Air_2.dat');

$lcf -> pause;

$lcf->clean;

$lcf->po->start_plot;
$lcf->po->set(e_norm=>0, e_der=>1);
$lcf -> plot_fit;

print "Showing SnO2 and H2-H2 fit for Air\n";
print $lcf->report;
$option = <STDIN>;

