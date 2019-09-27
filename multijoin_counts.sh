#!/bin/bash
# Recurisve join

# Defining the recursve function in case of three or more files to be joined.

join_rec() {
	if test "$#" -eq 1
	then
		join -t $'\t' -a 1 -e 0 -o auto - "$1"
	else
		f="$1"
		shift
		join -t $'\t' -a 1 -e 0 -o auto - "$f" | join_rec "$@"
	fi
}


# The body of the script

if test "$#" -lt 2
then
	echo You need at least two files to be joined.
	echo "Usage: ./multijoin_counts.sh <template> <file_1> <file_2> ... <file_n>"
elif test "$#" -eq 2
then
	join -t $'\t' -a 1 -e 0 -o auto "$1" "$2"
else
	f1="$1"
	f2="$2"
	shift 2
	join -t $'\t' -a 1 -e 0 -o auto "$f1" "$f2" | join_rec "$@"
fi


