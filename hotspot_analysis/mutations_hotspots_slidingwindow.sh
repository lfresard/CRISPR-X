#!/bin/bash
#LF
#Mai 2016
n=$1
mismatch=$2
H1=$3
H2=$4
WORK_DIR=$5
BAM_DIR=$6
chr=$7
HTSEQCount=/users/lfresard/software/HTSeq-0.6.1/scripts/htseq-count
mode=$8
read_length=75
window_size=$((H2-H1))

date

#!/bin/bash
# elif statements
if [ "$mode" == "strict" ]
then
	if [[ "$read_length" -gt "$window_size" ]]
	then
		echo "read length greater than window size"
		echo "Strict mode"
		#1/FILTER BAM FOR READS IN THE HOSTPOT
		echo "------------------------------------------"
		echo "1/FILTER BAM FOR READS IN THE HOSTPOT"
		echo "------------------------------------------"
		samtools view $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted.bam ${chr}:${H1}-${H2} > $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}.sam
		wait
		cat $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}.sam | awk -v h1="$H1" -v h2="$H2" -v rl="$read_length" ' {if( h1>=$4 && h2<=($4+rl)) print }'> $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}_strictoverlap.sam
		echo "Filter reads strictly spanning hotspot done"
		echo ""
		echo ""
		#2/PROCESS THIS FILTERED BAM INTO PYTHON SCRIPT TO COUNT NUMBER OF MUTATIONS
		echo "------------------------------------------"
		echo "2/PROCESS THIS FILTERED SAM INTO PYTHON SCRIPT TO COUNT NUMBER OF MUTATIONS"
		echo "------------------------------------------"
		cd $WORK_DIR
		python /users/lfresard/CRISPR-X/scripts/getnumber_mutations_read.py $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}_strictoverlap.sam $H1 $H2
		echo "mutation counts on reads spanning hotspot done"
		date

	else
		echo "read length smaller than window size"
		echo "Strict mode"
		#1/FILTER BAM FOR READS IN THE HOSTPOT
		echo "------------------------------------------"
		echo "1/FILTER BAM FOR READS IN THE HOSTPOT"
		echo "------------------------------------------"
		
		echo -e ${chr}'\twindows\tregion\t'${H1}'\t'${H2}'\t.\t.\t.\tID "window1"'> $BAM_DIR/temp_${H1}-${H2}.gff
		
		
		echo "Mark reads spanning only the set window"
		samtools view $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted.bam |  htseq-count -f sam -s no -t region -m intersection-strict -i ID -o $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}_intersectonly.sam - $BAM_DIR/temp_${H1}-${H2}.gff
		
		wait
		
		echo "Get reads that match the window"
		grep window1 $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}_intersectonly.sam > $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}_intersectonly_matchreads.sam
		
		wait
		echo "Remove sam file generated by htseq"
		
		rm $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}_intersectonly.sam 
		rm $BAM_DIR/temp_${H1}-${H2}.gff
		#samtools view $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted.bam ${chr}:${H1}-${H2} > $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}.sam
		wait
		
		echo "Filter reads strictly spanning hotspot done"
		echo ""
		echo ""
		
		
		#2/PROCESS THIS FILTERED BAM INTO PYTHON SCRIPT TO COUNT NUMBER OF MUTATIONS
		echo "------------------------------------------"
		echo "2/PROCESS THIS FILTERED SAM INTO PYTHON SCRIPT TO COUNT NUMBER OF MUTATIONS"
		echo "------------------------------------------"
		
		cd $WORK_DIR
		python /users/lfresard/CRISPR-X/scripts/getnumber_mutations_read.py $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}_intersectonly_matchreads.sam $H1 $H2
		
		echo "mutation counts on reads spanning hotspot done"
		
		date
		
	fi
elif [ "$mode" == "soft" ]
then
	echo "Soft mode"
	#1/FILTER BAM FOR READS IN THE HOSTPOT
	echo "------------------------------------------"
	echo "1/FILTER BAM FOR READS IN THE HOSTPOT"
	echo "------------------------------------------"

	samtools view $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted.bam ${chr}:${H1}-${H2} > $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}.sam
	wait
	
	echo "Filter reads strictly spanning hotspot done"
	echo ""
	echo ""
	
	
	#2/PROCESS THIS FILTERED BAM INTO PYTHON SCRIPT TO COUNT NUMBER OF MUTATIONS
	echo "------------------------------------------"
	echo "2/PROCESS THIS FILTERED SAM INTO PYTHON SCRIPT TO COUNT NUMBER OF MUTATIONS"
	echo "------------------------------------------"
	
	cd $WORK_DIR
	python /users/lfresard/CRISPR-X/scripts/getnumber_mutations_read.py $BAM_DIR/CX${n}_n${mismatch}_mapq30_sorted_${H1}-${H2}.sam $H1 $H2
	
	echo "mutation counts on reads spanning hotspot done"
	
	date
	
	
	else
	echo "Please enter sctrict or soft mode"
fi
