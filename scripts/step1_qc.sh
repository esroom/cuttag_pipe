#!/bin/bash

# 定义输入文件夹和输出文件夹
FILE=$1
OUTPUT_DIR=$2
fastqc_dir=$3
cores=$4
multiqc=$5
# 检查输出文件夹是否存在，如果不存在则创建
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# 遍历输入文件夹中的所有FASTQ文件并执行FastQC分析

if [ -f "$FILE" ]; then
    echo "Processing $FILE ..."
    while IFS= read -r line
    do
        r1=`echo ${line} | awk '{print $4}'`
        r2=`echo ${line} | awk '{print $5}'`
        ${fastqc_dir} -t ${cores}  -o ${OUTPUT_DIR}/output ${fastqc_dir} ${r1}
        ${fastqc_dir} -t ${cores}  -o ${OUTPUT_DIR}/output ${fastqc_dir} ${r2}
        # 你可以在这里对每一行进行处理
    done < "$FILE"
    
    # 运行完fastqc后，使用multiqc进行汇总
    ${multiqc} ${OUTPUT_DIR}/output/ -o ${OUTPUT_DIR}/multiqc
else
    echo "No files found in $FILE"
fi 


echo "FastQC analysis complete. Results are in $OUTPUT_DIR"\
echo "Step1 complete." > ${OUTPUT_DIR}/shell/step1_qc.sh.sign
