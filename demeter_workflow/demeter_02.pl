#!/usr/bin/perl

use Demeter qw(:fit);

sub get_data{
	my $athena_name =  shift;
	my $crystal_name = shift;
	
	unlink "fes2.iff" if (-e "fes2.iff");
	print "Import data from an Athena project file\n";
	my $prj = Demeter::Data::Prj -> new(file=>$athena_name);
	my $data = $prj -> record(1);
	$data ->set(fft_kmin   => 3,	       fft_kmax   => 12,
			bft_rmin   => 1.2,         bft_rmax   => 4.1,
		);

	$data->set_mode(screen  => 0, backend => 1); #, file => ">fes2.iff", );
	$data -> plot_with('gnuplot');    ## similar to the :plotwith pragma

	my @gds =  (Demeter::GDS -> new(gds => 'guess', name => 'alpha', mathexp => 0),
			Demeter::GDS -> new(gds => 'guess', name => 'amp',   mathexp => 1),
			Demeter::GDS -> new(gds => 'guess', name => 'enot',  mathexp => 0),
			Demeter::GDS -> new(gds => 'guess', name => 'ss',    mathexp => 0.003),
			Demeter::GDS -> new(gds => 'guess', name => 'ss2',   mathexp => 0.003),
			Demeter::GDS -> new(gds => 'def',   name => 'ss3',   mathexp => 'ss2'),
			Demeter::GDS -> new(gds => 'guess', name => 'ssfe',  mathexp => 0.003),
		);

	my $atoms = Demeter::Atoms->new(file=>$crystal_name);
	my $feff = Demeter::Feff -> new(atoms=>$atoms);
	$feff   -> set(workspace=>"temp", screen=>0);
	$feff   -> run;
	print "Done with feff\n";
	my @sp   = @{$feff->pathlist};
	
	#print $feff -> intrp;
	#exit;

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

	my $fit = Demeter::Fit -> new(name  => 'FeS2 fit',
					  gds   => \@gds,
					  data  => [$data],
					  paths => \@paths
					 );
	print "about to fit\n";
	$fit -> fit;

	$data->po->set(plot_data => 1, plot_fit  => 1, );
	$data->plot('rmr');
	$data->pause;

	my $keypress = <STDIN>;


	my ($header, $footer) = ("Fit to FeS2 data", q{});
	$fit -> logfile("fes2.log", $header, $footer);
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
	# open input file and get data
	my ($athena_data, $feff_data) = get_data($athena_file, $crystal_file);
	# save the athena project
    #save_athena($athena_file, $input_data);
	# print parameters and present options
	#select_task($input_data, $athena_file);
	exit;
}

start();