#!/bin/bash

FILE=$1
OUTPUT_DIR=$2
bowtie2_dir=$3
cores=$4
ref=$5
spike_in_ref=$6


if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

[ ! -d "${OUTPUT_DIR}/output/bowtie2_summary" ] && mkdir ${OUTPUT_DIR}/output/bowtie2_summary

#如果去接头，则使用去接头后数据， 以R1_val_1.fq.gz结尾

#cores=12
#ref=/home/syl/Genome/mm10/mm10
if [ -f "$FILE" ]; then
    echo "Processing $FILE ..."
    while IFS= read -r line
    do
      r1=`echo ${line} | awk '{print $4}'`
      r2=`echo ${line} | awk '{print $5}'`
      sampleName=`echo ${line} | awk '{print $2}'`_`echo ${line} | awk '{print $3}'`
      bowtie2 --local --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 \
        --phred33 -I 10 -X 700 -p ${cores} -x ${ref} \
        -1 $r1 -2 $r2 \
        -S ${OUTPUT_DIR}/output/${sampleName}_bowtie2.sam   &> ${OUTPUT_DIR}/output/bowtie2_summary/${sampleName}_bowtie2.txt

    # 比对到spike-in
      bowtie2 --local --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 \
        --phred33 --no-dovetail --no-overlap -I 10 -X 700 -p ${cores} -x ${ref} \
        -1 $r1 -2 $r2 \
        -S ${OUTPUT_DIR}/output/${sampleName}_bowtie2_spikeIn.sam   &> ${OUTPUT_DIR}/output/bowtie2_summary/${sampleName}_bowtie2_spikeIn.txt
    done < $FILE
fi

