#!/bin/bash

# A scrip to autmatically choose the best model (and parameters) of protein evolution for a trimmed alignment,
# and run the phylognentic analysis with RAxML.
# The best model will be chosen according to the AICc.


# If no parameters are given, print usage
if test $# -eq 0
then
	echo
	echo "USAGE: $0 aln1.fasta aln2.faa aln3.phy ..."
	echo
	exit
fi

start_date=$(date)

echo
echo "A total of $# alignments will be analyzed with ProtTest3 and RAxML."
echo "These alignments are: "$@"."
echo
echo "Start date: $start_date."

for aln in "$@"
do
	echo
	echo "####################################################################################################"
	echo
	aln_name=$(echo "$aln" | sed -e 's/\.\w\+$//')
	echo "Analyzing alignment $aln with ProtTest3:"
	echo
	echo "java -jar /home/usuario/Apps/prottest3-master/dist/prottest-3.4.2.jar -i $aln -o $aln_name.PROTTEST -all-distributions -F -AIC -BIC -AICC -DT -all -S 1 -threads 4 1>/dev/null" | bash -v

	# Parsing the ProtTest3 output file to get the model and parameters
	# Choosing of the best model will be based on the AICc.
	# The ranking of the models according to other criteria can be inspected in the *PROTTEST file for each alignment.
	
	PROT_MODEL="" # Set to empty
	PROT_MODEL=$(sed -e '1,/Table/d;/Relative/,$d;/-------/d;/model/d' $aln_name.PROTTEST | sed -e 's/[0-9]\+\.[0-9]\+//g;s/)//g;s/(//g' | sort -g -k3,4 | sed -e '2,$d' | awk '{print $1}' | sed -e 's/+/ /g' | awk 'BEGIN {FS=" ";OFS=" "} {print $1}') # Scalar variable
	
	PROT_PARAM="" # Set to empty
	PROT_PARAM=($(sed -e '1,/Table/d;/Relative/,$d;/-------/d;/model/d' $aln_name.PROTTEST | sed -e 's/[0-9]\+\.[0-9]\+//g;s/)//g;s/(//g' | sort -g -k3,4 | sed -e '2,$d' | awk '{print $1}' | sed -e 's/+/ /g' | awk 'BEGIN {FS=" ";OFS=" "} {print $2,$3,$4}')) # Array

	rmdir snapshot # Not useful
	echo
	echo "The best model according to the AICc is: $PROT_MODEL."
	echo "The parameters are: ${PROT_PARAM[@]}."
	echo
	echo "Analyzing alignment $aln with RAxML:"
	i_par="" # Set empty variable for I parameter
	f_par="" # Set empty variable for F parameter
	g_par="" # Set empty variable for G parameter
	model_par="" # Set empty variable for model
	# The avobe variables are set to empty in case that they contain any value from the analysis of a previous alignment.
	
	# The model to be used in RAxML

	case $PROT_MODEL in
		Blosum62) model_par="BLOSUM62";;
		CpREV) model_par="CPREV";;
		Dayhoff) model_par="DAYHOFF";;
		DCMut) model_par="DCMUT";;
		FLU) model_par="FLU";;
		HIVb) model_par="HIVB";;
		HIVw) model_par="HIVW";;
		JTT) model_par="JTT";;
		LG) model_par="LG";;
		MtArt) model_par="MTART";;
		MtMam) model_par="MTMAM";;
		MtREV) model_par="MTREV";;
		RtREV) model_par="RTREV";;
		VT) model_par="VT";;
		WAG) model_par="WAG";;
	esac	
	# The  parameters to be used in RAxML
	for i in ${PROT_PARAM[@]}
	do
		case $i in
			I) i_par="I";;
			F) f_par="F";;
			*) continue;;
		esac
	done
	
	echo
	# -x and -p should be random so...
	x_par=$(echo $[ ($RANDOM % ($[99999 - 10000] + 1)) + 10000 ]) # A random number of five digits
	p_par=$(echo $[ ($RANDOM % ($[99999 - 10000] + 1)) + 10000 ]) # A random number of five digits

	echo "raxmlHPC-PTHREADS-AVX2 -T 4 -f a -m PROTGAMMA$i_par$model_par$f_par -x $x_par -p $p_par -# autoMRE -s $aln -n $aln_name.raxml-$i_par$model_par$f_par.TREE 1>/dev/null" | bash -v

	echo

done

echo "####################################################################################################"
echo

end_date=$(date)

echo "Finish date: $end_date."
echo
