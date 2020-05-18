#!/bin/bash 

############################ Usage and Help #########################################################################################

# Some variables
SCRIPT=$(basename ${BASH_SOURCE[0]})
BOLD="\033[1m"
OFF="\033[0m"
# echo -e '\033[1mYOUR_STRING\033[0m'

# Help message function
HELP () {
    echo
    echo -e "${BOLD}Usage:${OFF}\n"
    echo -e " $SCRIPT [-options] -p <hmm_profile> <protein_fasta_files>"
    echo
    echo -e "${BOLD}Examples:${OFF}\n"
    echo -e " $SCRIPT -e 1e-20 -c 0.9 -n NRT2-1 -p NRT2.hmm *pep"
    echo -e " $SCRIPT -g -c 0.9 -n NRT2-1 -p NRT2.hmm *pep"
    echo -e " $SCRIPT -p NRT2.hmm *pep"
    echo
    echo -e "${BOLD}Description:${OFF}\n"
    echo -e " The ${BOLD}$SCRIPT${OFF} command allows you to search and retrieve"
    echo -e " protein sequences from multiple fasta files using a hmm profile,"
    echo -e " either gnerated with hmmer3 or downloaded from pfam."
    echo
    echo -e "${BOLD}Dependecies:${OFF}\n"
    echo -e " The ${BOLD}hmmer3${OFF} and ${BOLD}emboss${OFF} packages must be installed (in path)."
    echo
    echo -e "${BOLD}Options:${OFF}\n"
    echo -e " -p\tHmm profile, e.g. NTR2.hmm.\n"
    echo -e " -e\tValue for the --E and --domE options of the ${BOLD}hmmsearch${OFF} command, e.g. 1-e20 (a single value for both)."
    echo -e "   \tNot compatible with -g.\n"
    echo -e " -g\tUse gathering threshold (--cut_ga of hmmer3). Not compatible with -e.\n"
    echo -e " -c\tCoverage (percentage). Values between 0 and 1, e.g. 0.8.\n"
    echo -e " -n\tName to be appended to the output directory name.\n"
    echo -e " -h\tPrint help."
    echo
    echo -e "${BOLD}Output:${OFF}\n"
    echo -e " Directories:"
    echo -e "  out\t\tContains default outputs."
    echo -e "  tblout\tContains output per sequence in tabular format."
    echo -e "  domtblout\tContains output per domain in tabular format."
    echo -e "  list\t\tContains lists of sequence identifiers."
    echo -e "  fasta\t\tContains the retrieved sequences in fasta format." 
    echo 
    echo -e " Files:"
    echo -e "  log.txt\tContains all info that was displayed on screen."
    echo -e "  errorlog.txt\tContains all errors."
    echo -e "  counts.csv\tContains the counts of the retrieved sequences per datset."
    echo 
}


################################################### Funtion definition #########################################################

ls_strip () {
    echo "$1" | sed -e 's/^\(.*\/\)\?\(.*\)\..*$/\2/'
}



get_list() {
	awk -v c_option=$c_option 'BEGIN {
	FS=" +"
	OFS="\t"
}

/^[^#]/ {
	my_var=$6
	seen[$1] += (($17 + 1) - $16)
}

END {
	min_per=int((my_var * c_option) + 0.5)
	for (i in seen) {
		if (seen[i] >= min_per ) {
			print i
		}
	}
}' $1

}

############################################# Parameters #####################################################################

# If no input, print usage
if test "$#" -eq 0
    then
    echo -e "\nUsage: $SCRIPT [-options] -p <hmm_profile> <protein_fasta_files>"
    echo -e "\nFor more help, use: $SCRIPT -h.\n"
    exit
fi

# Parse options with getopts
INVOCATION=()
while getopts ":p:e:gc:n:h" option; do
    case $option in
        p) 
           INVOCATION+=("-p $OPTARG")  
           p_option="$OPTARG"
           p_name=$(ls_strip $OPTARG) ;;
        e) 
           INVOCATION+=("-e $OPTARG")
           e_option=$OPTARG
           e_name="_ev$OPTARG" ;;
        g) 
           INVOCATION+=("-g ")
           g_option="cutga"
           g_name="_cutga" ;;
        c) 
           INVOCATION+=("-c $OPTARG")
           c_option=$OPTARG 
           c_name="_c$c_option";;
        n) 
           INVOCATION+=("-n $OPTARG")
           n_option=$(echo _$OPTARG) ;;
        h) 
           HELP
           exit ;;
        *) echo "Unknown option: $option"
           exit ;;
            
    esac
done

shift $[ $OPTIND - 1 ]

# You can only use -e or -g (or empty), not -e and -g at the same time
if [ -n "$e_option" ] && [ -n "$g_option" ]
then
    echo -e "\nError: Either -e or -g can be specified, not both. Type $SCRIPT -h for help.\n"
    exit
fi

# Don't accept empty files
if test "$#" -eq 0
then
    echo -e "\nError: At least one fasta file must be specified.\n"
    exit
fi

# You need to specify a hmm profile
if [ -z "$p_option" ]
then
    echo -e "\nError: A hmm profile must be specified.\n"
    exit
fi

# Verify if file exists and is not empty
for i in "$@"
do
    if [ -s $i ]
    then
        continue
    else
        echo -e "\nError: $i doesn't exist or is empty\n."
        exit
    fi
done

# If not coverage provided, default is 0
if [ -z "$c_option" ]
then
    c_option=0
    echo -e "\nCoverage not provided, default is $c_option.\n"
else
    echo -e "\nCoverage provided, $c_option"
fi


##################################################### Analysis can begin #######################################################33

# Save main director, not that is needed, but just in case
main_dir=$(pwd)

# Save the date and time when the analysis started
THE_DATE=$(date +%Y%m%d-%H%M%S)

# Create output directory and its structure
output=$(echo "$THE_DATE"_"$p_name""$e_name""$g_name""$c_name""$n_option")
mkdir -p $output/{tblout,out,domtblout,list,fasta}
touch $output/{log,errorlog,counts.csv}
echo -e "sp\t$output" >> $output/counts.csv

# Create log and error log
exec 1> >(tee $output/log)
exec 2> $output/errorlog

# Start message
echo -e "\nYou invoked:\n"
echo -e "$SCRIPT ${INVOCATION[@]} $@"
echo
echo -e "Date-Time: $THE_DATE"
echo
echo "Output directory: "$output
echo

########################################################### Hmmsearch  ###########################################################

# Choose the type of hmmsearch
echo -e "\nDoing hmmsearches...\n"
if [ -n "$e_option" ]
then
    for i in "$@"
    do
        filename=$(ls_strip $i)
        echo "hmmsearch --cpu 4 -E $e_option --domE $e_option --domtblout $output/domtblout/$filename.domtblout --tblout $output/tblout/$filename.tblout -o $output/out/$filename.out $p_option $i" | bash -v 2>&1
    done
elif [ -n "$g_option" ]
then
    for i in "$@"
    do
        filename=$(ls_strip $i)
        echo "hmmsearch --cpu 4 --cut_ga --domtblout $output/domtblout/$filename.domtblout --tblout $output/tblout/$filename.tblout -o $output/out/$filename.out $p_option $i" | bash -v 2>&1
    done
else
    for i in "$@"
    do
        filename=$(ls_strip $i)
        echo "hmmsearch --cpu 4 --domtblout $output/domtblout/$filename.domtblout --tblout $output/tblout/$filename.tblout -o $output/out/$filename.out $p_option $i" | bash -v 2>&1
    done
fi


############################################################## get lists #############################################################

echo -e "\nGetting lists of sequence names...\n"

for i in "$@" # direct from main input
do
    shortname=$(ls_strip $i)
    filename=$(echo $output/domtblout/$(ls_strip $i).domtblout)
    if [ -s $filename ]
    then
        echo -e "Getting sequence names from $filename"
		get_list $filename > $output/list/$shortname.txt
    fi
done


####################################################### retrieve sequencse ############################################################

echo -e "\nRetrieving sequences from datasets...\n"

for i in "$@" # direct from main input
do
    echo "Retrieving sequences from $i"
    shortname=$(ls_strip $i)
    if [ -s $output/list/$shortname.txt ]
    then
        cat $output/list/$shortname.txt | while read seqname
        do
            seqret -auto -stdout $i:$seqname >> $output/fasta/$shortname.fasta
        done
    else
        continue
    fi
done

####################################################### Counts ########################################################################

echo -e "\nCounting...\n"
for i in "$@" # direct from main input
do
    shortname=$(ls_strip $i)
    if [ -s $output/fasta/$shortname.fasta ]
    then
        grep -H -c -e ">" $output/fasta/$shortname.fasta | sed -e 's|^.*/||;s|\.fasta:|\t|' >> $output/counts.csv
    else
        echo -e "$shortname\t0" >> $output/counts.csv
    fi
done

######################################################### Ending message #############################################################

enddate=$(date +%Y%m%d)
endtime=$(date +%H:%M:%S)

echo -e "If you can read this message, congrats, your analysis concluded succesfully."
echo -e "However, please check the log and errorlog files in the output directory, and your results."
echo
echo -e "Analysis finalized on $enddate, $endtime."



echo
