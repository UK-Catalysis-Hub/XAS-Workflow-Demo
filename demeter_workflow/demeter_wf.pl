#!/usr/bin/perl

# All the tasks of the basic workflow can be performed in Demeter,
# this script shows how to do it.
# 
# The code for each task has been documented in the demeter programing guide
# Example derived from code published at:
#   https://bruceravel.github.io/demeter/documents/DPG

# First example of importing a Mu(e) data file and plotting it

use Demeter;
#Athena   | 1.1. Import data                |File: fes2_rt01_mar02.xmu                      | 
#         | 1.2. Normalisation              |Parameters: Pre-edge range = -117.00 to 30.000 |
#         | 1.3. Save Athena Project        |                                               |File: FeS2_dmtr.prj

my $data = Demeter::Data -> new(file => "fes2_rt01_mar02.xmu",
                                name => 'FeS2_xmu',
                               );
$data -> plot('E');
sleep 5;