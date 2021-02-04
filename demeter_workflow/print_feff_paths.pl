# #!/usr/bin/perl
# use Demeter;

# ## Deserializing feff.yaml;
# my $feff = Demeter::Feff -> new("feff/feff.yaml");
# my @list_of_paths = $feff->pathlist;

# ### The 6 scattering geometries that contribute to path #2:
# my $sp = $list_of_paths[0];
# my $j=1000;
# foreach my $s ($sp->all_strings) {
  # print $sp -> pathsdat(index=>++$j, string=>$s, angles=>1);
# };

 #!/usr/bin/perl
 use Demeter;

 my $feff = Demeter::Feff -> new(file => "FeS2_feff.inp");
 $feff -> set(workspace => "feff/", screen => 0,);
 $feff -> potph;
 $feff -> pathfinder;

 my @list_of_paths = @{ $feff-> pathlist };
 my $len = scalar @list_of_paths; 
 print "length of paths: $len\n";
 printf "%0000s %-8s %-8s %-16s %-5s %-5s %-18s\n", '#', 'degen', 'Reff', 'Sc. Path', 'I', 'Legs','type'; 
 my $indx = 0;
 foreach my $sp (@list_of_paths) {
    my $this = Demeter::Path->new(parent => $feff,
                                   sp     => $sp);
    $this -> plot('r');
	printf "%0000s %s %s\n",$indx, $sp -> n, $this->label;
	$indx += 1;
 }






 # my @list_of_paths = @{ $feff-> pathlist };
 # my $len = scalar @list_of_paths; 
 # print "length of paths: $len\n";
 # foreach (@list_of_paths[0..1]) {
    # my $this = Demeter::Path->new(parent => $feff,
                                   # sp     => $_);
    # $this -> plot('r');
	# printf "%s\n",$this->label;
	# my @sp_keys = keys {%$this}; 
	# # for my $a_k (@sp_keys ){
		# # printf "printf \"%s: Xs\\n\", \$this -> %s;\n", $a_k, $a_k;
	# # }
	# printf "update_fft: %s\n", $this -> update_fft;
	# printf "intrpline: %s\n", $this -> intrpline;
	# printf "bvscat: %s\n", $this -> bvscat;
	# printf "delr_stored: %s\n", $this -> delr_stored;
	# printf "dphase: %s\n", $this -> dphase;
	# printf "e0: %s\n", $this -> e0;
	# printf "parentgroup: %s\n", $this -> parentgroup;
	# printf "degen: %s\n", $this -> degen;
	# printf "mode: %s\n", $this -> mode;
	# printf "update_path: %s\n", $this -> update_path;
	# printf "update_bft: %s\n", $this -> update_bft;
	# printf "datagroup: %s\n", $this -> datagroup;
	# printf "valence_scat: %s\n", $this -> valence_scat;
	# printf "ei_value: %s\n", $this -> ei_value;
	# printf "delr_stderr: %s\n", $this -> delr_stderr;
	# printf "ei_stored: %s\n", $this -> ei_stored;
	# printf "trouble: %s\n", $this -> trouble;
	# printf "file: %s\n", $this -> file;
	# printf "id: %s\n", $this -> id;
	# printf "xdi_will_be_cloned: %s\n", $this -> xdi_will_be_cloned;
	# printf "c4: %s\n", $this -> c4;
	# printf "is_ss: %s\n", $this -> is_ss;
	# printf "third_stored: %s\n", $this -> third_stored;
	# printf "delr_value: %s\n", $this -> delr_value;
	# printf "dphase_stored: %s\n", $this -> dphase_stored;
	# printf "xdifile: %s\n", $this -> xdifile;
	# printf "fourth: %s\n", $this -> fourth;
	# printf "phase_array: %s\n", $this -> phase_array;
	# printf "parent: %s\n", $this -> parent;
	# printf "s02: %s\n", $this -> s02;
	# printf "fourth_stored: %s\n", $this -> fourth_stored;
	# printf "fourth_stderr: %s\n", $this -> fourth_stderr;
	# printf "ei: %s\n", $this -> ei;
	# printf "pc: %s\n", $this -> pc;
	# printf "sp: %s\n", $this -> sp;
	# printf "delr: %s\n", $this -> delr;
	# printf "name: %s\n", $this -> name;
	# printf "geometry: %s\n", $this -> geometry;
	# printf "frozen: %s\n", $this -> frozen;
	# printf "c3: %s\n", $this -> c3;
	# printf "third_stderr: %s\n", $this -> third_stderr;
	# printf "sigma2: %s\n", $this -> sigma2;
	# printf "label: %s\n", $this -> label;
	# printf "dphase_value: %s\n", $this -> dphase_value;
	# printf "include: %s\n", $this -> include;
	# printf "ei_stderr: %s\n", $this -> ei_stderr;
	# printf "s02_stored: %s\n", $this -> s02_stored;
	# printf "fourth_value: %s\n", $this -> fourth_value;
	# printf "default_path: %s\n", $this -> default_path;
	# printf "reff: %s\n", $this -> reff;
	# printf "amp_array: %s\n", $this -> amp_array;
	# printf "is_col: %s\n", $this -> is_col;
	# printf "spgroup: %s\n", $this -> spgroup;
	# printf "dphase_stderr: %s\n", $this -> dphase_stderr;
	# printf "e0_stored: %s\n", $this -> e0_stored;
	# printf "s02_value: %s\n", $this -> s02_value;
	# printf "bvabs: %s\n", $this -> bvabs;
	# printf "plottable: %s\n", $this -> plottable;
	# printf "zcwif: %s\n", $this -> zcwif;
	# printf "sigma2_stderr: %s\n", $this -> sigma2_stderr;
	# printf "save_mag: %s\n", $this -> save_mag;
	# printf "third_value: %s\n", $this -> third_value;
	# printf "data: %s\n", $this -> data;
	# printf "c2: %s\n", $this -> c2;
	# printf "sigma2_stored: %s\n", $this -> sigma2_stored;
	# printf "Index: %s\n", $this -> Index;
	# printf "s02_stderr: %s\n", $this -> s02_stderr;
	# printf "n: %s\n", $this -> n;
	# printf "xdi: %s\n", $this -> xdi;
	# printf "sentinal: %s\n", $this -> sentinal;
	# printf "c1: %s\n", $this -> c1;
	# printf "sigma2_value: %s\n", $this -> sigma2_value;
	# printf "group: %s\n", $this -> group;
	# printf "e0_stderr: %s\n", $this -> e0_stderr;
	# printf "pathtype: %s\n", $this -> pathtype;
	# printf "plot_after_fit: %s\n", $this -> plot_after_fit;
	# printf "third: %s\n", $this -> third;
	# printf "valence_abs: %s\n", $this -> valence_abs;
	# printf "mark: %s\n", $this -> mark;
	# printf "folder: %s\n", $this -> folder;
	# printf "nleg: %s\n", $this -> nleg;
	# printf "e0_value: %s\n", $this -> e0_value;
	# printf "k_array: %s\n", $this -> k_array;  
 # };
 # $len = scalar @list_of_paths; 
 # print "length of paths: $len after plot\n";
 
# #print $feff -> intrp;
#$feff -> potph;
#$feff -> pathfinder;
# need to refresh list after reading with foreach
# @list_of_paths = @{ $feff-> pathlist };
# foreach  (@list_of_paths){
	# my $this = Demeter::Path->new(parent => $feff,
                                   # sp     => $_);
    # $this -> plot('r');
# };

@list_of_paths = @{ $feff-> pathlist };
my $indx = 0;
foreach my $sp (@list_of_paths[0..87]){
	#my @sp_keys = keys {%$sp}; 
	# for my $a_k (@sp_keys ){
		# printf "printf \"%s: Xs\\n\", \$sp -> %s;\n", $a_k, $a_k;
	# }
	# printf " : %s \n", $indx;
	# printf "name: %s\n", $sp -> name;
	# printf "rleg: %s\n", $sp -> rleg;
	# printf "betakey: %s\n", $sp -> betakey;
	# printf "ipot: %s\n", $sp -> ipot;
	# printf "rank_rmaxi: %s\n", $sp -> rank_rmaxi;
	# printf "rank_kmini: %s\n", $sp -> rank_kmini;
	# printf "group_name: %s\n", $sp -> group_name;
	# printf "rank_rmini: %s\n", $sp -> rank_rmini;
	# printf "cleanup: %s\n", $sp -> cleanup;
	# printf "rankings: %s\n", $sp -> rankings;
	# printf "angleout: %s\n", $sp -> angleout;
	# printf "fs: %s\n", $sp -> fs;
	# printf "orig_nnnn: %s\n", $sp -> orig_nnnn;
	# printf "nleg: %s\n", $sp -> nleg;
	# printf "randstring: %s\n", $sp -> randstring;
	# printf "rank_rmin: %s\n", $sp -> rank_rmin;
	printf " %s | %s\n",$indx, $sp -> string;
	# printf "site_fraction: %s\n", $sp -> site_fraction;
	# printf "rankdata: %s\n", $sp -> rankdata;
	# printf "n: %s\n", $sp -> n;
	# printf "trouble: %s\n", $sp -> trouble;
	# printf "beta: %s\n", $sp -> beta;
	# printf "degeneracies: %s\n", $sp -> degeneracies;
	# printf "fromnnnn: %s\n", $sp -> fromnnnn;
	# printf "fuzzy: %s\n", $sp -> fuzzy;
	# printf "file: %s\n", $sp -> file;
	# printf "Type: %s\n", $sp -> Type;
	# printf "group: %s\n", $sp -> group;
	# printf "pathfinder_index: %s\n", $sp -> pathfinder_index;
	# printf "rank_rmax: %s\n", $sp -> rank_rmax;
	# printf "datagroup: %s\n", $sp -> datagroup;
	# printf "etakey: %s\n", $sp -> etakey;
	# printf "etanonzero: %s\n", $sp -> etanonzero;
	# printf "frozen: %s\n", $sp -> frozen;
	# printf "heapvalue: %s\n", $sp -> heapvalue;
	# printf "anglein: %s\n", $sp -> anglein;
	# printf "betanotstraightish: %s\n", $sp -> betanotstraightish;
	# printf "cosinout: %s\n", $sp -> cosinout;
	# printf "spline: %s\n", $sp -> spline;
	# printf "folder: %s\n", $sp -> folder;
	# printf "halflength: %s\n", $sp -> halflength;
	# printf "rank_kmin: %s\n", $sp -> rank_kmin;
	# printf "eta: %s\n", $sp -> eta;
	# printf "mark: %s\n", $sp -> mark;
	# printf "rank_kmaxi: %s\n", $sp -> rank_kmaxi;
	# printf "plottable: %s\n", $sp -> plottable;
	# printf "mode: %s\n", $sp -> mode;
	# printf "weight: %s\n", $sp -> weight;
	# printf "sentinal: %s\n", $sp -> sentinal;
	# printf "zcwif: %s\n", $sp -> zcwif;
	# printf "pathfinding: %s\n", $sp -> pathfinding;
	# printf "feff: %s\n", $sp -> feff;
	# printf "nkey: %s\n", $sp -> nkey;
	# printf "steps: %s\n", $sp -> steps;
	# printf "rank_kmax: %s\n", $sp -> rank_kmax;
	# printf "pathtype: %s\n", $sp -> pathtype;
	# printf "data: %s\n", $sp -> data;
	# my $j=1000;
	# foreach my $s ($sp->all_strings) {
		# print $sp -> pathsdat(index=>++$j, string=>$s, angles=>1);
	# };
	$indx += 1;
};

printf "%-4s %-8s %-8s %-20s %-5s %-5s %-18s\n", '#', 'degen', 'Reff', 'Sc. Path', 'I', 'Legs','type'; 
$indx = 0;
foreach my $sp (@list_of_paths){
	my $this = Demeter::Path->new(parent => $feff,
				sp     => $sp);
	#my @sp_keys = keys {%$sp}; 
	# for my $a_k (@sp_keys ){
		# printf "printf \"%s: Xs\\n\", \$sp -> %s;\n", $a_k, $a_k;
	# }
	printf "%-4s %-8s %-8s %-20s %-5s %-5s %-18s\n", $indx, $sp -> n, $sp -> fuzzy, $this->label,$sp -> weight, $sp -> nleg, $sp -> Type;
	$indx += 1;
}


print_paths($feff,\@list_of_paths,0,9);

# foreach my $sp (@list_of_paths[0..1]){
	# printf "\n%-4s %-8s %-8s %-16s %-5s\n", $indx, $sp -> beta, $sp -> degeneracies,$sp -> heapvalue, $sp -> eta;	
	# my @beta = $sp -> eta;
	# my $len = scalar @beta;
	# print "Items in beta: $len\n";
	# my $idx = 0;
	# while($idx < $len){
		# printf "Beta %s: %s\n", $idx, $beta[$idx];
		# $idx +=1;
	# }
# }
sub print_paths{
	my $feff_data = $_[0];
	my @paths_list = @{$_[1]};
	my $from_p = $_[2];
	my $to_p = $_[3];
	printf "%-4s %-8s %-8s %-20s %-5s %-5s %-18s\n", '#', 'degen', 'Reff', 'Sc. Path', 'I', 'Legs','type'; 
	$indx = 0;
	foreach my $sp (@paths_list[$from_p..$to_p]){
		my $this = Demeter::Path->new(parent => $feff,
				sp     => $sp);
		printf "%-4s %-8s %-8s %-20s %-5s %-5s %-18s\n", $indx, $sp -> n, $sp -> fuzzy, $this->label,$sp -> weight, $sp -> nleg, $sp -> Type;
		$indx += 1;
	}
}
