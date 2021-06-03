#!/usr/bin/perl
use Demeter;
use Class::Inspector;

package DemeterCommon;

sub get_data{
	my $file_name = shift;
	my $group_name = shift;
	my $data = Demeter::Data -> new(file => $file_name, name => $group_name);
	return $data;
}

sub save_athena{
	my $file_name = shift;
	my $data = shift;
	# Save as athena project
	#   from https://github.com/bruceravel/demeter/blob/411cf8d2b28819bd7a21a29869c7ad0dce79a8ac/documentation/DPG/output.rst
	$data->write_athena($file_name, $data);
}

sub open_project{
	my $file_name =  shift;
	#open athena project and get data
	print "Opening Athena project file\n";
	my $prj = Demeter::Data::Prj -> new(file=>$file_name);
	my $data = $prj -> record(1);
	#get the group name (for batch is the same as the file name)
	print $data->name;
	print "****** Completed reading data *****\n";
	return $data
}

1;