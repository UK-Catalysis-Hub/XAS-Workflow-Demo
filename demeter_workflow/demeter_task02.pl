#!/usr/bin/perl

use Demeter qw(:fit);
use File::Path qw( make_path );

sub clear_screen{
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
}

sub save_artemis{
	my $file_name = shift;
	my $fit_data = shift;
	# Save as athena project
	#   from https://github.com/bruceravel/demeter/blob/411cf8d2b28819bd7a21a29869c7ad0dce79a8ac/documentation/DPG/output.rst
	#$fit_data->write($file_name, $fit_data);
	my @gds = $fit_data -> gds;
	write_parameters(@gds, $file_name);
	my @ssp = $fit_data -> paths;
	write_selected_paths(@ssp, $file_name);
}
	
sub get_data{
	my $athena_name =  shift;
	my $run_auto = shift;
	#open athena project and get data
	unlink "fes2.iff" if (-e "fes2.iff");
	if ($run_auto eq "N"){ print "Import data from an Athena project file\n";}
	my $prj = Demeter::Data::Prj -> new(file=>$athena_name);
	my $data = $prj -> record(1);
	#get the group name (for batch is the same as the file name)
	if ($run_auto eq "N"){ print ($data->name);}
	# set fit parameters ****This may need to be extracted to other process****
	$data ->set(fft_kmin   => 3,	       fft_kmax   => 12,
			bft_rmin   => 1.2,         bft_rmax   => 4.1,
		);
	$data->set_mode(screen  => 0, backend => 1); #, file => ">fes2.iff", );
	$data -> plot_with('gnuplot');    ## similar to the :plotwith pragma
	if ($run_auto eq "N"){ print "****** Completed reading data *****\n";}
	return $data
}

sub get_feff{
	my $crystal_name = shift;
	my $run_auto = shift;
	
	# open crystal file and run atoms and feff to get the paths
	
	my $atoms = Demeter::Atoms -> new();
	if (substr($crystal_name, -3,3 ) eq "cif"){
		$atoms->cif($crystal_name);
	}
	else
	{
		$atoms->file($crystal_name);
	}
	my $feff = Demeter::Feff -> new(atoms => $atoms);
	$feff   -> set(workspace=>"temp", screen=>0);
	$feff   -> run;
	$feff -> make_feffinp("full");
	if ($run_auto eq "N"){print "****** Done with feff *****\n";}
	return $feff
}

sub read_parameters{
	my @gds = @{$_[0]};
	my $filename = $_[1];
	my $w_print = "Y";
	if ($_[2]){
		$w_print = $_[2];
	}
	if ($w_print eq "Y"){
		print "***** Reading parameters ******\n";
		print "***** from $filename ******\n";
	}
	open(FH, '<', $filename) or die $!;
	while(<FH>){
		my $gds_str = $_;
		if ($w_print eq "Y") {print $gds_str;};
		push (@gds, Demeter::GDS -> simpleGDS( $gds_str ));
	};
	close(FH);
	return @gds;
}

sub add_parameter{
	my (@gds) = @{$_[0]};
	print "add parameter";
	print "type values for new parameter\n";
	my $add_name = "";
	while (length($add_name) < 1){	
		print "name:"; 
		$add_name = <STDIN>;
		chomp $add_name;
	}
	my $new_type = "";
	while (length($new_type) < 1 ){
		print "type valid: [guess, def, skip]:";
		$new_type = <STDIN>;
		chomp $new_type;
	}
	my $new_value = "";
	while (length($new_value) < 1){
		print "value (valid: [value or math expression]):";
		$new_value = <STDIN>;
		chomp $new_value;
	}
	print "note";
	my $new_note = <STDIN>;
	chomp $new_note;
	push(@gds, (Demeter::GDS -> new(name => $add_name, gds	 => $new_type, mathexp => $new_value, note => $new_note)));
	return @gds;
}

sub edit_parameter{
	my $par = $_[0];
	print "type new value or enter to keep current";
	printf "name (current %s):", $par->name;
	my $new_name = <STDIN>;
	chomp $new_name;
	if (length($new_name) < 1) {$new_name = $par->name}
	printf "type (current %s) valid: [guess, def, skip]:", $par->gds;
	my $new_type = <STDIN>;
	chomp $new_type;
	if (length($new_type) < 1) {$new_type = $par->gds}
	printf "value (current %s) valid: [value or expression]:", $par->mathexp;
	my $new_value = <STDIN>;
	chomp $new_value;
	if (length($new_value) < 1) {$new_value = $par->mathexp}
	printf "note (current %s):", $par->note;
	my $new_note = <STDIN>;
	chomp $new_note;
	if (length($new_note) < 1) {$new_note = $par->note}
	$par -> set(name => $new_name, gds	 => $new_type, mathexp => $new_value, note => $new_note);
}

# set guess parameters for amplitude, Delta E0, Delta R and sigma square to be 
# assigned to paths
sub set_parameters{
	# pass a reference to the array, then dereference it in the subroutine
	# https://www.perlmonks.org/?node_id=439926
	my @gds = @{$_[0]};
	my $option =0;
	while ($option != 5){
		print "************************************************************\n";
		print_parameters(\@gds);
		print "Options:\n";
		print "1) edit parameter\n";
		print "2) add parameter\n";
		print "3) delete parameter\n";
		print "4) read parameters from file\n";
		print "5) return\n";
		print "Your selection (1-5): ";
		$option = <STDIN>;
		if ($option == 1){
			print "edit parameter";
			print "parameter number:";
			my $p_num = <STDIN>;
			my $par = $gds[$p_num];
			edit_parameter($par);
		}
		elsif ($option  == 2){
			@gds = add_parameter(\@gds);
		}
		elsif ($option  == 3){
			print "delete parameter";
			print "parameter number:";
			my $d_num = <STDIN>;
			printf "Deleting %s: %s %s %s %s", $gds[$d_num]->name, $gds[$d_num]->gds, $gds[$d_num]->mathexp,$gds[$d_num]->note;
			splice(@gds, $d_num, 1)
		}
		elsif ($option  == 4){
			print "read from file";
			print "file name:";
			my $parameters_file = <STDIN>;
			chomp $parameters_file;
			@gds = read_parameters(\@gds, $parameters_file);
		}
		else {
			print "invalid selection\n";
		}
	}
	return @gds
}

sub print_parameters{
	print "***** Defined Parameters List ******\n";
	printf "%-7s %-8s %-8s %-16s %s\n", 'N', 'Name', 'type', 'value', 'note';
	my @gds = @{$_[0]};
	for my $i (0 .. $#gds) {	
		my $x = $gds[$i];
		my $gds_name = $x -> name;
		my $gds_type = $x -> gds;
		my $gds_value = $x -> mathexp;
		my $gds_note = $x -> note;
		printf "%-7s %-8s %-8s %-16s %s\n", $i, $gds_name, $gds_type, , $gds_value, $gds_note;
	}
}

sub read_selected{
	my $data = $_[0];
	my $feff = $_[1];
	my @sel_paths = @{$_[2]};
	my $filename = $_[3];
	my $w_print = "Y";
	if ($_[4]){
		$w_print = $_[4];
	}
	if ($w_print eq "Y"){
		print "***** Reading selected paths ******\n";
		print "***** From file $filename ******\n";
	}
	open(FH, '<', $filename) or die $!;
	my @fields = ();
	while(<FH>){
		my $gds_str = $_;
		@fields = split "," , $gds_str;
		my @a = (1..4);
		for my $i (@a){
			$fields[$i] =~ s/[\p{Pi}\p{Pf}'"]//g
		}
		my @list_of_paths = @{$feff->pathlist};
		foreach my $sp (@list_of_paths){
			if ($fields[0] == $sp -> nkey){
				my $this = Demeter::Path -> new(sp => $sp,
				  data   => $data,
				  s02    => $fields[1],
				  e0     => $fields[2],
				  delr   => $fields[3],
				  sigma2 => $fields[4],
				  include=> ($fields[5]==1),
				 );
				push (@sel_paths, $this);
			};
		}
	}
	my $pars = scalar @sel_paths;
	if ($w_print eq "Y"){
		print "***** Read $pars paths ******\n";
		print_selected_paths(\@sel_paths);
	}
	close(FH);
	return @sel_paths;
}

sub add_path{
	my $feff = $_[0];
	my $data = $_[1];
	my @paths = @{$_[2]};
	
	my @sp = @{$feff -> pathlist};
	my @sel_ids = get_selected_paths_ids(\@paths);
	my $all_paths = scalar @sp;
	my $p_num = "";
	while (not $p_num =~ /[0-9]+|c|C/){
		clear_screen;
		print "Adding paths\n";
		print "******* FEFF Paths *********\n";
		print_paths($feff, \@sp, \@sel_ids);
		print "${all_paths} FEFF Calculated paths\n";
		print "Path number to add ('c' to cancel):";
		$p_num = <STDIN>;
	}
	if ($p_num =~ /[0-9]+/){
		my $p_id = $sp[$p_num] -> nkey;
		if (not ($p_id ~~ @sel_ids)){
			print "values for path variables";
			printf "Amplitude factor S0^2:";
			my $new_s02 = <STDIN>;
			chomp $new_s02;
			if (length($new_s02) < 1) {$new_s02 = $paths[$p_num] -> s02;};
			printf "Energy shift Delta E0:";
			my $new_E0 = <STDIN>;
			chomp $new_E0;
			if (length($new_E0) < 1) {$new_E0 = $paths[$p_num]-> e0;};
			printf "Half path length adjustment Delta R:";
			my $new_dR = <STDIN>;
			chomp $new_dR;
			if (length($new_dR) < 1) {$new_dR = $paths[$p_num]-> delr;};
			printf "Mean square displacement Sigma^2:";
			my $new_sig2 = <STDIN>;
			chomp $new_sig2;
			push(@paths, Demeter::Path -> new(sp     => $sp[$p_num],
				  data   => $data,
				  s02    => $new_s02,
				  e0     => $new_E0,
				  delr   => $new_dR,
				  sigma2 => $new_sig2
				 ));
		}
	}
	return @paths;
}

sub select_paths{
	my $feff = $_[0];
    my $data = $_[1];
	my @paths = @{$_[2]};
	my @sp   = @{$feff->pathlist};
    # select paths and assign parameter variables
	my @sel_ids = get_selected_paths_ids(\@paths);
	my $option =0;
	while ($option != 5){
		print "************************************************************\n";
		@sel_ids = get_selected_paths_ids(\@paths);
		print_selected_paths(\@paths);
		# need to print selected paths
		print "Select paths\n";
		print "Options:\n";
		print "1) edit selected paths\n";
		print "2) add path\n";
		print "3) delete path\n";
		print "4) read selected parameters from file\n";
		print "5) return\n";
		print "Your selection (1-5): ";
		$option = <STDIN>;
		if ($option == 1){
			print "edit selected paths\n";
			print "path number:";
			my $p_num = <STDIN>;
			print "type new value or enter to keep current";
			printf "Amplitude factor S0^2(current %s):", $paths[$p_num] -> s02;
			my $new_s02 = <STDIN>;
			chomp $new_s02;
			if (length($new_s02) < 1) {$new_s02 = $paths[$p_num] -> s02;};
			printf "Energy shift Delta E0 (current %s):", $paths[$p_num] -> e0;
			my $new_E0 = <STDIN>;
			chomp $new_E0;
			if (length($new_E0) < 1) {$new_E0 = $paths[$p_num]-> e0;};
			printf "Half path length adjustment Delta R (current %s):", $paths[$p_num]-> delr;
			my $new_dR = <STDIN>;
			chomp $new_dR;
			if (length($new_dR) < 1) {$new_dR = $paths[$p_num]-> delr;};
			printf "Mean square displacement Sigma^2 (current %s):", $paths[$p_num]-> sigma2;
			my $new_sig2 = <STDIN>;
			chomp $new_sig2;
			if (length($new_sig2) < 1) {$new_sig2 = $paths[$p_num]-> sigma2;};
			printf "Include in fit (current %s) valid [1,0]:", $paths[$p_num]-> include;
			my $new_include = <STDIN>;
			chomp $new_include;
			if (length($new_include) < 1) {$new_include = $paths[$p_num]-> include;};
			$paths[$p_num] -> set(s02 => $new_s02, e0	 => $new_E0, delr => $new_dR, sigma2 => $new_sig2, include => $new_include);
		}
		elsif ($option == 2){
			@paths = add_path($feff, $data, \@paths);
		}
		elsif ($option == 3){
			print "delete selected path\n";
			print "path number:";
			my $d_num = <STDIN>;
			splice(@paths, $d_num, 1)
		}
		elsif ($option == 4){
			print "read selected paths from file";
			print "file name:";
			my $parameters_file = <STDIN>;
			chomp $parameters_file;
			@paths = read_selected($data, $feff, \@paths, $parameters_file);
		}
		elsif ($option == 5){
			print "Return\n";
			foreach my $p (@paths) {
				$p->sp->cleanup(0);
			};
		}
		else{
			print "invalid option";
		}
	}
	return @paths;
}

# print feff paths 
#  - needs feff data, paths list, from and to.
#  - an array of ids for previously selected paths
#  - the ids are nkey (alternatively could use string) 
sub print_paths{
	my $feff_data = $_[0];
	my @paths_list = @{$_[1]};
	my @sel_path_ids = @{$_[2]};
	printf "%-2s%-5s %-6s %-7s %-30s %-3s %-4s %-18s\n", '#','Selct.', 'degen', 'Reff', 'Sc. Path', 'I', 'Legs','type', ''; 
	my $indx = 0;
	foreach my $sp (@paths_list){
		my $this = Demeter::Path->new(parent => $feff_data,
				sp     => $sp);
		my $p_id = $sp -> nkey;
		my $selected = "";
		if ($p_id ~~ @sel_path_ids){
			$selected = "true";
		}
		printf "%-2s%-5s %-6s %-7s %-30s %-3s %-4s %-18s\n", $indx, $selected, $sp -> n, $sp -> fuzzy, $this->name, $sp -> weight, $sp -> nleg, $sp -> Type;
		$indx += 1;
	}
}

sub print_selected_paths{
	my @paths_list = @{$_[0]};
	printf "%-2s%-27s %-10s %-10s %-10s %-10s %-10s %-10s\n", '#', 'Sc. Path', 's0^2', 'Delta e0', 'Delta R', 'sigma^2', 'include', 'sp index'; 
	my $indx = 0;
	foreach my $s_path (@paths_list){
		printf "%-2s%-27s %-10s %-10s %-10s %-10s %-10s %-10s\n", $indx, $s_path -> label, $s_path -> s02, $s_path -> e0 ,$s_path -> delr, $s_path -> sigma2, $s_path -> include, $s_path -> sp ->nkey;
		$indx += 1;
	}
}

sub get_selected_paths_ids{
	my @paths_list = @{$_[0]};
	my @path_ids = ();
	foreach my $s_path (@paths_list){#[$from_p..$to_p]){
		my $sp = $s_path -> sp;
		push @path_ids, $sp-> nkey;
	}
	return @path_ids
}

sub run_fit{
	my $data = $_[0];
	my @paths = @{$_[1]};
	my @gds = @{$_[2]};
	my $artemis_f = $_[3];
	my $w_print = "Y";
	if ($_[4]){
		$w_print = $_[4];
	}
	
	my $f_out = $data->name;
	
	my $fit = undef;

	my $len = scalar @gds; 
    print "parameters: $len\n";
	if ($len < 1) {
		print "Parameters not set, cannot fit";
		<STDIN>;
		return $fit;
	}
	$len = scalar @paths; 
    print "paths: $len\n";
	if ($len < 1) {
		print "Paths not selected, cannot fit";
		<STDIN>;
		return $fit;
	}
	# use parameters, data and paths to perform the fit
	$fit = Demeter::Fit -> new(name  => "${f_out}_fit",
					  gds   => \@gds,
					  data  => [$data],
					  paths => \@paths
					 );
	print "about to fit $f_out\n";
	$fit -> fit;
	if ($w_print eq "Y"){
		#show fit plot
		$data->po->set(plot_data => 1, plot_fit  => 1);
		$data->plot('rmr');
		$data->pause;
		#$fit -> interview;
		my $keypress = <STDIN>;
	}
	
	# Write log file is written. 
	# The first argument of the logfile method is the name of the output log
	# file. The other two arguments, contain user-specified text that is 
	# written to the beginning and end of log file.
	my ($header, $footer) = ("Fit to $f_out data", q{});
	$fit -> logfile(".\\${artemis_f}_fit\\${f_out}_fit.log", $header, $footer);
	# This serialization file is simply a normal zip file containing the 
	# serializations of all the objects used in the fit along with a log file
	# and a few other results of the fit. 
	$fit -> freeze(file=>".\\${artemis_f}_fit\\${f_out}_fit.dpj");
	$data->save("fit", ".\\${artemis_f}_fit\\${f_out}.fit");
	return $fit;
}

# Attempt to retrieve vatiables and selected paths from
# artemis files
# $artemis_f.gds : parameters file
# $artemis_f.csv : selected paths file
sub get_artemis_parameters{
	my @gds = @{$_[0]};
	my $artemis_file = $_[1];
	my $w_print = "Y";
	if ($_[2]){
		$w_print = $_[2];
	}
	my $gds_file = ".\\${artemis_file}_fit\\${artemis_file}.gds";
	if (-e $gds_file) {
		if ($w_print eq "Y") {print "reading parameters from $gds_file";}
		@gds = read_parameters(\@gds, $gds_file, $w_print);
	}
	else {
		print "could not find parameters file $gds_file \n";
	}
	return @gds;
}
# Attempt to retrieve vatiables and selected paths from
# artemis files
# $artemis_f.gds : parameters file
# $artemis_f.csv : selected paths file
sub get_artemis_sel_sp{
	my @s_paths = @{$_[0]};
	my $data = $_[1];
	my $feff = $_[2];
	my $artemis_file = $_[3];
	my $w_print = "Y";
	if ($_[4]){
		$w_print = $_[4];
	}
	my $ssp_file = ".\\${artemis_file}_fit\\${artemis_file}.csv";
	if (-e $ssp_file) {
		if ($w_print eq "Y") {print "reading paths from $ssp_file";}
		@s_paths = read_selected($data, $feff, \@s_paths, $ssp_file, $w_print);
	}
	else {
		print "could not find paths file $ssp_file \n";
	}
	return @s_paths;
}

# write parameters to file
sub write_parameters{
	my (@gds) = @{$_[0]};
	my $artemis_file = $_[1];
	my $gds_file = ".\\${artemis_file}_fit\\${artemis_file}.gds";
	open my $out, '>:encoding(UTF-8)', $gds_file;
	for my $i (0 .. $#gds) {	
		my $x = $gds[$i];
		my $gds_name = $x -> name;
		my $gds_type = $x -> gds;
		my $gds_value = $x -> mathexp;
		my $gds_note = $x -> note;
		print {$out} "$gds_type $gds_name = $gds_value\n";
	}
	close $out;
}

sub write_selected_paths{	
	my @paths_list = @{$_[0]};
	my $artemis_file = $_[1];
	my $ssp_file = ".\\${artemis_file}_fit\\${artemis_file}.csv";
	
	open my $out, '>:encoding(UTF-8)', $ssp_file;	
	foreach my $s_path (@paths_list){
		my $sp_id = $s_path ->sp->nkey;
		my $sp_s02 = $s_path -> s02;
		chomp $sp_s02;
		# trim from https://perlmaven.com/trim
		$sp_s02 =~ s/^\s+|\s+$//g;
		my $sp_e0 = $s_path -> e0;
		$sp_e0 =~ s/^\s+|\s+$//g;
		my $sp_delr = $s_path -> delr;
		$sp_delr =~ s/^\s+|\s+$//g;
		my $sp_sigma2 = $s_path -> sigma2;
		$sp_sigma2 =~ s/^\s+|\s+$//g;
		my $sp_include = $s_path -> include;
		print {$out} "${sp_id},'${sp_s02}','${sp_e0}','${sp_delr}','${sp_sigma2}',${sp_include}\n";
	}
	close $out;
}

# interactive run for setting parameters, selecting paths and 
sub select_task{
	my $data = shift;
	my $feff = shift;
	my $artemis_f = shift;
	
	my @gds_parameters = ();
	my @selected_paths = ();
	# If artemis file(s) exist retrieve them to set vatiables and selected paths
	# $artemis_f.gds : parameters file
	# $artemis_f.csv : selected paths file
	@gds_parameters = get_artemis_parameters(\@gds_parameters, $artemis_f);
	@selected_paths = get_artemis_sel_sp(\@selected_paths, $data, $feff, $artemis_f);
	
	my $curve_fit = undef;
	# loop on the following three subtasks
	# 3. Select paths
	# 4. Set parameters
	# 5. Run fit
	# 6. save the athena project
	
	my $option = 0;
	while ($option != 4){
		#show_parameters($data);
		print "************************************************************\n";
		print "Options:\n";
		print "1) Set parameters\n";
		print "2) Select paths\n";
		print "3) Run fit\n";
		print "4) Save project and exit\n";
		print "Your selection (1-4): ";
		$option = <STDIN>;
		if ($option == 1){
			print "Set paramenters\n" ;
			@gds_parameters = set_parameters(\@gds_parameters);
			write_parameters(\@gds_parameters, $artemis_f);
		}
		elsif ($option  == 2){
			print "Select paths\n";
			@selected_paths = select_paths($feff, $data, \@selected_paths);
			write_selected_paths(\@selected_paths, $artemis_f);
		}
		elsif ($option == 3){
			print "Run fit\n";
			$curve_fit = run_fit($data, \@selected_paths, \@gds_parameters, $artemis_f);
		}
		elsif ($option == 4){
			print "Save project and exit\n";
			save_artemis($artemis_f, $curve_fit);
		}
		else {
			print "invalid selection\n";
		}
		clear_screen;
	}
}

sub run_batch{
	my $data = shift;
	my $feff = shift;
	my $artemis_f = shift;
	
	my @gds_parameters = ();
	my @selected_paths = ();
	# If artemis file(s) exist retrieve them to set vatiables and selected paths
	# $artemis_f.gds : parameters file
	# $artemis_f.csv : selected paths file
	@gds_parameters = get_artemis_parameters(\@gds_parameters, $artemis_f, "N");
	@selected_paths = get_artemis_sel_sp(\@selected_paths, $data, $feff, $artemis_f, "N");
	my $curve_fit = undef;
	$curve_fit = run_fit($data, \@selected_paths, \@gds_parameters, $artemis_f, "N");
}

sub start{
	
	my $athena_file = "FeS2.prj";
	my $crystal_file = "FeS2.inp";
    my $artemis_file = "FeS2_dmtr";
	my $run_auto = "N";

	# if no argument passed, show warning and use defaults
	if (!@ARGV or $#ARGV < 2) {
		print "Need to provide three argument\n - Athena file name";
		print "\n - Crystal information file";
		print "\n - Artemis file(s) base\n";
		print "Arguments passed: $#ARGV + 1";
	}
	else{
		my $test_argument = $ARGV[0];
		if (-e $test_argument) {
			if ($run_auto ne "N"){print "Reading from file: $test_argument\n";}
			$athena_file = $test_argument;
			}
		else{
			print "Input file does not exist: $test_argument\n";
			print "Reading from default file: $athena_file\n";
		}
		$test_argument = $ARGV[1];
		if (-e $test_argument) {
			if ($run_auto ne "N"){print "Reading from file: $test_argument\n";}
			$crystal_file = $test_argument;
		}
		else{
			print "Input file does not exist: $test_argument\n";
			print "Reading from default file: $crystal_file\n";
		}
		$artemis_file = $ARGV[2];
	}
	if (@ARGV and $#ARGV > 2)
	{
		$run_auto = $ARGV[3];
	}
	
	if ($run_auto eq "N") {
		print "Fit using Demeter ", $Demeter::VERSION, $/;
	}
	
	if ( !-d ".\\${artemis_file}_fit" ) {
		make_path ".\\${artemis_file}_fit" or die "Failed to create path: .\$artemis_file";
	}
	
	# artemis task broken down
	# 1. Import Athena data (.prj)
	my $athena_data= get_data($athena_file, $run_auto);
	
	# 2. Import crystal data (.cif) and calcultate paths (run atoms and feff)
	my $feff_data = get_feff($crystal_file, $run_auto);
	
	# 3. loop on the select path, set parameters, and run fit
	if ($run_auto eq "N"){
	  select_task($athena_data, $feff_data, $artemis_file);
	}
	else{
		# run in batch mode (needs artemis files to exist)
		run_batch($athena_data, $feff_data, $artemis_file);
	}
	exit;
}
# run from command line with:
#   perl demeter_task02.pl athena_file(.prj) crystal_file(.inp/.cif) artemis_file(.fpj)
# for instance:
#   perl demeter_task02.pl FeS2_dmtr.prj FeS2.inp FeS2_dmtr
#   perl demeter_task02.pl .\rh4co\rh4co000001.prj ..\cif_files\C12O12Rh4.cif rh4co_ox
#   perl demeter_task02.pl .\rh4co\rh4co000499.prj ..\cif_files\C12O12Rh4.cif rh4co_ox N
start();
