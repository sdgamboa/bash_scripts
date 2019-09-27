#!/bin/bash
# Recursive join
# with headers

# Define a recursive function in case that three or more files need to be joined.

join_rec() {
	if test "$#" -eq 1
	then
		join -t $'\t' -a 1 -e 0 -o auto --header - "$1"
	else
		f="$1"
		shift
		join -t $'\t' -a 1 -e 0 -o auto --header - "$f" | join_rec "$@"
	fi
}


# The body of the script

if test "$#" -lt 2
then
	echo You need at least two files to be joined.
	echo "Usage: ./multijoin_counts.sh <template> <file_1> <file_2> ... <file_n>"
elif test "$#" -eq 2
then
	join -t $'\t' -a 1 -e 0 -o auto --header "$1" "$2"
else
	f1="$1"
	f2="$2"
	shift 2
	join -t $'\t' -a 1 -e 0 -o auto --header "$f1" "$f2" | join_rec "$@"
fi


