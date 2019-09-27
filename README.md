## My Bash Scripts

This repository contains some bash scripts that I often use to
do my work on the linux terminal.

### multijoin_counts.sh and multijoin_counts_h.sh
##### Joins together many tables of counts.

These two scripts are useful when you need to use the join command to join two or more numeric tables.
If some values are missing they will be filled with zeros (that's why the _counts_ part of the name). 


### protrax.sh
##### Explore the phylogeny of several multiple sequence alignments of proteins

This script takes a multiple sequence aligment of proteins (preferentially trimmed) as input and automatically
determines the best model of protein of evolution with ProtTest3 and runs a ML phylogenetic tree with
RaXML. Before using this script you will need to modify it to indicate the path to the ProtTest3 and 
RaXML executables. The autoMRE option of bootstopping criterion is activated to automatically determine 
the number of bootstrap replicates.
