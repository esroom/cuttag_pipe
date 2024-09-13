#!/bin/bash
set -uex 
# 定义输入文件夹和输出文件夹
FILE=$1
OUTPUT_DIR=$2
trim_galore_dir=$3
cores=$4

# 检查输出文件夹是否存在，如果不存在则创建
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    mkdir  $OUTPUT_DIR/output/
    mkdir  $OUTPUT_DIR/shell
fi

if [ -f "$FILE" ]; then
    echo "Processing $FILE ..."
    while IFS= read -r line
    do
        r1=`echo ${line} | awk '{print $4}'`
        r2=`echo ${line} | awk '{print $5}'`
        sample_dir=`echo ${line} | awk '{print $2}'`_`echo ${line} | awk '{print $3}'`
        ${trim_galore_dir} -q 25 --phred33 --length 30 --stringency 3 -j ${cores} --gzip  --paired \
          -o  $OUTPUT_DIR/output/${sample_dir} \
          $r1 $r2
    done < "$FILE"
    
else
    echo "No files found in $FILE"
fi


echo "Step2 cutadapt analysis complete. Results are in $OUTPUT_DIR"\
echo "Step2 complete." > ${OUTPUT_DIR}/shell/step2_cutadapt.sh.sign
