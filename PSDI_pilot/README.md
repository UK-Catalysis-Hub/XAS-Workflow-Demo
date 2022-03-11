# PSDI Workflow
This folder contains the script and input files required to reproduce the 
results of nine papers from the UKCH which are linked to the published data
required to reproduce the results.

The script is build followint the Athena, Artemis and examples provided by Bruce Ravel 
([XAS fitting example](https://github.com/bruceravel/XAS-Education/tree/master/Examples/FeS2),
[Bruce Ravel XAS course 2011](https://www.diamond.ac.uk/Instruments/Spectroscopy/Techniques/XAS.html)).

This example uses Demeter and Perl directly, instead of using Athena and Artemis.

The script is meant to be run from the command line as:
 `perl reproduce_pub.pl athena groups file (.csv ) operartions list (.csv)`

For instance, the provided files:
 `perl reproduce_pub.pl pub_037_athena.csv pub_037_operations.csv`
 
# Athena groups file
The athena groups file is a csv file that contains a list of athena project 
files and groups to be used in the script to reproduce the results.

The file should contain no headers, and each line contains three columns: Athena
file, Data group name, and Display name. For instance, the first two lines of the 
pub_037_athena.csv file presented below include the name of two athena files, 
including the path to get to the files, the name of the groups to be imported 
(used) and the names to be assigned to those groups in the operations.

`..\psdi_data\pub_037\XAFS_prj\SnO2 0.9 2.6-13.5 gbkg.prj,SnO2 0.9,SnO2`<br>
`..\psdi_data\pub_037\XAFS_prj\Sn K-edge\PtSn_OCO.prj,PtSn_OCO rebinned,air`


## Operations File
The operations list file is a csv file that contains a list of operations 
which need to be performed to reproduce published results.
The file should contain no headers, and each line contains five columns: Operation
ID, data group ids, plot parameters, display text, and plot limits. For instance 
the first three lines of pub_037_operations.csv shown below.

`1,0|1|2|3|4,1|0|1|0|0|0|0|0|0,Show normalised E plot for first five groups,20|60|-20|180`<br>
`2,0|1|2|3|4,1|0|1|1|0|0|0|0|0,Plot first derivate for first five groups,20|60|-15|7`<br>
`3,3|0|4,0|0|0|1|0|0|0|0|0,Showing SnO2 and Sn foil fit for H2,20|60|-20|60`<br>

The codes for the operations are (first column):
1 Show normalised mu on E plot 
2 Show plot for first derivate of mu on E
3 Perform LCF

The second column contains a list of groups, using the indices of the groups imported, 
in the order they were read (starting from index 0). The list is separated by bars (|).
For operations 1 and 2, the order in which the groups are listed should match the order
in which the groups need to be displayed.
For operation 3 (LCF), the first element of the list is the group to be fitted, and the 
rest of the elements are the standards to be used for fitting.

The third column contains a list of nine boolean flags (0 = inactive, 1 = active), 
also separated by bars (|). The nine boolean flags correspond to nine elements 
which can be included in the plots: e_mu, e_bkg, e_norm, e_der, e_pre, e_post, 
e_i0, e_signal, e_markers. 

The fourth column contains the displayed text which indicates which operation is
being performed.

The fifth column contains a list of four bar (|) separated values used to 
indicate the max and min values in the x axis. The first two indicate the -/+ 
offset from E0, the second pair 

## Example files
The provied example files (pub_037_athena.csv and pub_037_operations.csv) 
are required to reproduce the results from Huang et. al.[1], using 
supporting data published with the article [2]. 

## Acknowledgements
The funding for the research and development of this example came from the 
collaboration of UKCH with the STFC Scientific Computing Department in the 
"Phisical Sciences Research Infrastructure (PSDI) Phase 1 Pilot" (ESPRC 
EP/W032252/1).

## References
1. Huang, Haoliang, Nassr, Abu Bakr Ahmed Amine, Celorrio, Verónica, 
   Taylor, S. F. Rebecca, Puthiyapura, Vinod Kumar, Hardacre, Christopher, 
   Brett, Dan J. L., Russell, Andrea E. (2018) Effects of heat treatment 
   atmosphere on the structure and activity of Pt3Sn nanoparticle 
   electrocatalysts: a characterisation case study. Faraday Discussions. 
   V. 208. pp. 555-573. [DOI: 10.1039/c7fd00221a](https://doi.org/10.1039/c7fd00221a)
2. Huang, Haoliang, Nassr, Abubakr AA and Celorrio, Veronica (2018) 
   Dataset for Effects of heat treatment atmosphere on the structure and
   activity of Pt3Sn nanoparticle electrocatalysts: a characterisation case
   study. University of Southampton [DOI: 10.5258/SOTON/D0408](https://dx.doi.org/10.5258/SOTON/D0408).
   
   