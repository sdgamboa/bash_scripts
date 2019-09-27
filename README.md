# My Bash Scripts

This repository contains some bash scripts that I often use to
do my work on the linux terminal.

## multijoin_counts.sh and multijoin_counts_h.sh
**Join together many tables of counts**  
These two scripts are useful when you need to use the join command over two or more tables with numbers.
If some values are missing they will be filled with zeros (that's why the _counts_ part of the name). 
The `multijoin_counts_h.sh` script takes headers into account. 

## protrax.sh
**Explore the phylogeny of several multiple sequence alignments of proteins**  
This script takes one or several multiple sequence alignments of proteins (preferentially trimmed) as input and automatically
determines the best model of protein of evolution with ProtTest3 and runs a ML phylogenetic tree with
RaXML for each of them. Before using this script you will need to modify it to indicate the path to the ProtTest3 and 
RaXML executables. The autoMRE option of bootstopping criterion is activated to automatically determine 
the number of bootstrap replicates.
