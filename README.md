# A Few Bash Scripts

This repository contains some custom-made bash scripts that I often use to
do my work on the linux terminal.

## hmm_retrieve.sh
**Search and retrieve protein sequences from a set of protein datasets by using hmmer and seqret.**<br>
The inputs are a hmmprofile and one or several protein sequence datasets in fasta format.
The output is a folder with the results: list of ids, retrieved sequences in fasta, hmmsearch results (normal, tabular,
and domain output formats), table of counts, and log files.

Get help:
```
./hmm_retrieve.sh -h
```

## multijoin_counts.sh and multijoin_counts_h.sh
**Join together many tables of counts.**<br>
These two scripts are useful when you need to use the join command over two or more tables with numbers.
If some values are missing they will be filled with zeros (that's why the _counts_ part of the name). 
The `multijoin_counts_h.sh` script takes headers into account. 


Print how to use it:

```
./multijoin_counts.sh
```
Or:

```
./multijoin_counts_h.sh
```

## protrax.sh
**Explore the phylogeny of several multiple sequence alignments of proteins.**<br>
This script takes one or several multiple sequence alignments of proteins (preferentially trimmed) as input, and it automatically
determines the best model of protein of evolution with ProtTest3 and runs a ML phylogenetic tree with
RaXML for each alignment. Before using this script you will need to modify it to indicate the path to the ProtTest3 and 
RaXML executables. The autoMRE option of bootstopping criterion is activated to automatically determine 
the number of bootstrap replicates.

Print how to use it:

```
./protrax.sh
```

