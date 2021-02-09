#!/usr/bin/perl
use Demeter qw(:fit);


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

sub read_selected{
	print "***** Reading selected paths ******\n";
	my $data = $_[0];
	my $feff = $_[1];
	my @sel_paths = @{$_[2]};
	my $filename = $_[3];
	print "***** From file $filename ******\n";
	open(FH, '<', $filename) or die $!;
	my @fields = ();
	while(<FH>){
		my $gds_str = $_;
		#print $gds_str;
		@fields = split "," , $gds_str;
		#print @fields;
		my @list_of_paths = @{$feff->pathlist};
		foreach my $sp (@list_of_paths){
			my @a = (1..4);
			for my $i (@a){
				$fields[$i] =~ s/[\p{Pi}\p{Pf}'"]//g
			}
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
	print "***** Read $pars paths ******\n";
	
	close(FH);
	return @sel_paths;
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


my $athena_file = "FeS2_dmtr.prj";
my $feff = Demeter::Feff -> new(file => "FeS2_feff.inp");
$feff -> set(workspace => "feff/", screen => 0,);
$feff -> potph;
$feff -> pathfinder;

my $athena_data= get_data($athena_file);

my @selected_sps = ();
@selected_sps = read_selected($athena_data, $feff, \@selected_sps, 'fes2_paths.csv');
print_selected_paths(\@selected_sps);

# #save only sp_index, s02,De0,DR, s2, include
# 1, 'amp', 'enot', 'alpha*reff', 'ss', 1
# 7, 'amp', 'enot', 'alpha*reff', 'ss2', 1
# 13, 'amp', 'enot', 'alpha*reff', 'ss3', 1
# 15, 'amp', 'enot', 'alpha*reff', 'ssfe', 1
# 1010, 'amp', 'enot', 'alpha*reff', 'ss * 1.5', 1
# 1015, 'amp', 'enot', 'alpha*reff', 'ss/2 + ssfe', 1
# 1005, 'amp', 'enot', 'alpha*reff', 'ss*2', 1
# 1000005, 'amp', 'enot', 'alpha*reff', 'ss*2', 1
# 1000001, 'amp', 'enot', 'alpha*reff', 'ss*4', 1
# # Sc. Path                    s0^2       Delta e0   Delta R    sigma^2    include    sp index
# 0 [feff.inp.hQCrcQ] S.1       amp        enot       alpha*reff ss         1          1
# 1 [feff.inp.hQCrcQ] S.2       amp        enot       alpha*reff ss2        1          7
# 2 [feff.inp.hQCrcQ] S.3       amp        enot       alpha*reff ss3        1          13
# 3 [feff.inp.hQCrcQ] Fe.1      amp        enot       alpha*reff ssfe       1          15
# 4 [feff.inp.hQCrcQ] S.1 S.2   amp        enot       alpha*reff ss*1.5     1          1010
# 5 [feff.inp.hQCrcQ] S.1 Fe.1  amp        enot       alpha*reff ss/2 + ssfe 1          1015
# 6 [feff.inp.hQCrcQ] S.1 S.1   amp        enot       alpha*reff ss*2       1          1005
# 7 [feff.inp.hQCrcQ] S.1       amp        enot       alpha*reff ss*2       1          1000005
# 8 [feff.inp.hQCrcQ] S.1       amp        enot       alpha*reff ss*4       1          1000001