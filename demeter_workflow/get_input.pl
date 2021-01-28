#!/usr/bin/perl
sub clear_screen{
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
}

sub show_graphs{
	clear_screen;
	print "Show graphs\n";
	while ($option != 3){
		clear_screen;
		print "Options:\n";
		print "1) Show R\n";
		print "2) Show R Normalised\n";
		print "3) return\n";
		print "Your selection (1-3): ";
		$option = <STDIN>;
		if ($option == 1) {
			print "Show R"
		}
		elsif ($option  == 2) {
			print "Show R Normalised"
		}
		elsif ($option == 3) {
			print "Return"
		}
		else {
			print "invalid selection\n";
		}
	}
	print
}

sub show_parameters{
	clear_screen;
	print "Show parameters\n";
}

sub set_parameters{
	clear_screen;
	print "Set parameters\n";
}

sub save_and_exit{
	clear_screen;
	print "Save Athena project and exit\n";
}

sub select_task{
	while ($option != 4){
		clear_screen;
		print "Options:\n";
		print "1) show graph\n";
		print "2) show parameters\n";
		print "3) set parameters\n";
		print "4) save athena project and exit\n";
		print "Your selection (1/2/3/4): ";
		$option = <STDIN>;
		if ($option == 1) {
			show_graphs;
		}
		elsif ($option  == 2) {
			show_parameters;
		}
		elsif ($option == 3) {
			set_parameters;
		}
		elsif ($option == 4) {
			save_and_exit;
		}
		else {
			print "invalid selection\n";
		}
	}
}

select_task;