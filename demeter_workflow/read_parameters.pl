#!/usr/bin/perl
use Demeter qw(:fit);

sub set_parameters{
	print "***** Set parameters ******\n";
	my @gds = @{$_[0]};
	my $filename = $_[1];

	open(FH, '<', $filename) or die $!;

	while(<FH>){
		my $gds_str = $_;
		print $gds_str;
		
		push (@gds, Demeter::GDS -> simpleGDS( $gds_str ));
	};
	close(FH);
	return @gds;
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

my @gds = ();
@gds = set_parameters(\@gds, 'FeS2_gds.gds');
print_parameters(\@gds)