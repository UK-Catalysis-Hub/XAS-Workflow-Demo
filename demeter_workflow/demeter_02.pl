#!/usr/bin/perl

use Demeter qw(:fit);

sub clear_screen{
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
}

sub get_data{
	my $athena_name =  shift;
	#open athena project and get data
	unlink "fes2.iff" if (-e "fes2.iff");
	print "Import data from an Athena project file\n";
	my $prj = Demeter::Data::Prj -> new(file=>$athena_name);
	my $data = $prj -> record(1);
	# set fit parameters ****This may need to be extracted to other process****
	$data ->set(fft_kmin   => 3,	       fft_kmax   => 12,
			bft_rmin   => 1.2,         bft_rmax   => 4.1,
		);

	$data->set_mode(screen  => 0, backend => 1); #, file => ">fes2.iff", );
	$data -> plot_with('gnuplot');    ## similar to the :plotwith pragma
	print "****** Completed reading data *****\n";
	return $data
}
sub get_feff{
	my $crystal_name = shift;

	# open crystal file and run atoms and feff to get the paths
	my $atoms = Demeter::Atoms -> new(file => $crystal_name);
	my $feff = Demeter::Feff -> new(atoms => $atoms);
	$feff   -> set(workspace=>"temp", screen=>0);
	$feff   -> run;
	print "****** Done with feff *****\n";
	return $feff
}

sub set_parameters{
	# pass a reference to the array, then dereference it in the subroutine
	# https://www.perlmonks.org/?node_id=439926
	my (@gds) = @{$_[0]};
    # set guess parameters for amplitude, Delta E0, Delta R and sigma square to be 
	# assigned to paths
	@gds =  (Demeter::GDS -> new(gds => 'guess', name => 'alpha', mathexp => 0),
			Demeter::GDS -> new(gds => 'guess', name => 'amp',   mathexp => 1),
			Demeter::GDS -> new(gds => 'guess', name => 'enot',  mathexp => 0),
			Demeter::GDS -> new(gds => 'guess', name => 'ss',    mathexp => 0.003),
			Demeter::GDS -> new(gds => 'guess', name => 'ss2',   mathexp => 0.003),
			Demeter::GDS -> new(gds => 'def',   name => 'ss3',   mathexp => 'ss2'),
			Demeter::GDS -> new(gds => 'guess', name => 'ssfe',  mathexp => 0.003),
		);
	print_parameters(\@gds);
	<STDIN>;
	
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

sub select_paths{
	my $feff = shift;
    my $data = shift;
	my @sp   = @{$feff->pathlist};
	print $feff -> intrp;
	#exit;
	# select paths and assign parameter variables
	my @paths = ();
	push(@paths, Demeter::Path -> new(sp     => $sp[0],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ss'
					 ));
	push(@paths, Demeter::Path -> new(sp     => $sp[1],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ss2'
					 ));
	push(@paths, Demeter::Path -> new(sp     => $sp[2],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ss3'
					 ));
	push(@paths, Demeter::Path -> new(sp     => $sp[4],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ssfe'
					 ));
	push(@paths, Demeter::Path -> new(sp     => $sp[6],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ss*1.5'
					 ));
	push(@paths, Demeter::Path -> new(sp     => $sp[7],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ss/2 + ssfe'
					 ));
	push(@paths, Demeter::Path -> new(sp     => $sp[13],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ss*2'
					 ));
	push(@paths, Demeter::Path -> new(sp     => $sp[14],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ss*2'
					 ));
	push(@paths, Demeter::Path -> new(sp     => $sp[15],
					  data   => $data,
					  s02    => 'amp',
					  e0     => 'enot',
					  delr   => 'alpha*reff',
					  sigma2 => 'ss*4'
					 ));
	
	foreach my $p (@paths) {
	  $p->sp->cleanup(0);
	};
	<STDIN>;
	return @paths;
}

sub run_fit{
	my $data = $_[0];
	my @paths = @{$_[1]};
	my @gds = @{$_[2]};
	my $fit = undef;
	
	my $len = scalar @gds; 
    print "length of parameters: $len\n";
	if ($len < 1) {
		print "Parameters not set, cannot fit";
		<STDIN>;
		return $fit;
	}
	$len = scalar @paths; 
    print "length of paths: $len\n";
	if ($len < 1) {
		print "Paths not selected, cannot fit";
		<STDIN>;
		return $fit;
	}
	# use parameters, data and paths to perform the fit
	$fit = Demeter::Fit -> new(name  => 'FeS2 fit',
					  gds   => \@gds,
					  data  => [$data],
					  paths => \@paths
					 );
	print "about to fit\n";
	$fit -> fit;
	#show fit plot
	$data->po->set(plot_data => 1, plot_fit  => 1, );
	$data->plot('rmr');
	$data->pause;

	my $keypress = <STDIN>;

	my ($header, $footer) = ("Fit to FeS2 data", q{});
	$fit -> logfile("fes2.log", $header, $footer);
	return $fit;
}

sub select_task{
	my $data = shift;
	my $feff = shift;
	my @gds_parameters = ();
	my @selected_paths = ();
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
		}
		elsif ($option  == 2){
			print "Select paths\n";
			@selected_paths = select_paths($feff, $data);
		}
		elsif ($option == 3){
			print "Run fit\n";
			my $len = scalar @gds_parameters; 
			print "lenth of parameters: $len\n";
			$len = scalar @selected_paths; 
			print "lenth of paths: $len\n";
			$curve_fit = run_fit($data, \@selected_paths, \@gds_parameters);
		}
		elsif ($option == 4){
			print "Save project and exit\n";
			#save_artemis($athena_f, $data);
		}
		else {
			print "invalid selection\n";
		}
		clear_screen;
	}
}

sub start{
	print "Fit to FeS2 data using Demeter ", $Demeter::VERSION, $/;
	my $athena_file = "FeS2_dmtr.prj";
	my $crystal_file = "FeS2.inp";
    my $artemis_file = "FeS2_dmtr.fpj";

	# if no argument passed, show warning and use defaults
	if (!@ARGV or $#ARGV < 2) {
		print "Need two provide three argument\n - Athena file name";
		print "\n - Crystal information file";
		print "\n - Artemis file name\n";
		print "Arguments passed: $#ARGV + 1";
	}
	else{
		my $test_argument = $ARGV[0];
		if (-e $test_argument) {
			print "Reading from file: $test_argument\n";
			$athena_file = $test_argument;
			}
		else{
			print "Input file does not exist: $test_argument\n";
			print "Reading from default file: $athena_file\n";
		}
		$test_argument = $ARGV[1];
		if (-e $test_argument) {
			print "Reading from file: $test_argument\n";
			$crystal_file = $test_argument;
		}
		else{
			print "Input file does not exist: $test_argument\n";
			print "Reading from default file: $crystal_file\n";
		}
		$artemis_file = $ARGV[2];
	}

	# break out of the process
	# 1. Import Athena data (.prj)
	my $athena_data= get_data($athena_file);
	
	# 2. Import crystal data (.cif) and calcultate paths (run atoms and feff)
	my $feff_data = get_feff($crystal_file);
	
	# loop on the select path, set parameters, and run fit
	select_task($athena_data, $feff_data);
	
	exit;
}

start();