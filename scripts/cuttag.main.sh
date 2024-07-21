#!/bin/bash

# 显示帮助信息
usage() {
  echo "Usage: $0 -i sample.txt -s soft.cfg -t cuttag.cfg -o output_dir"
  exit 1
}

# 检查输入参数
while getopts "i:s:t:o:" opt; do
  case ${opt} in
    i)
      input_file=${OPTARG}
      ;;
    s)
      soft_file=${OPTARG}
      ;;
    t)
      cuttag_file=${OPTARG}
      ;;
    o)
      outdir=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done

# 检查是否所有参数都已提供
if [ -z "${input_file}" ] || [ -z "${soft_file}" ] || [ -z "${cuttag_file}" ] || [ -o "${outdir}" ]; then
  usage
fi

#!/bin/bash

# 检查并创建目录的函数
check_and_create_dirs() {
  base_dir=$1
  subdirs=("input" "output" "shell")

  for subdir in "${subdirs[@]}"; do
    dir="${base_dir}/${subdir}"
    if [ ! -d "${dir}" ]; then
      echo "Directory ${dir} does not exist. Creating..."
      mkdir -p "${dir}"
      echo "Directory ${dir} created."
    else
      echo "Directory ${dir} already exists."
    fi
  done
}



###########  Step1 qc  #############
step1_outdir=${outdir}/Step1_qc

#  判断是否存在 shell/step1.run.sign文件，如果存在，则跳过
if [ -f "${step1_outdir}/shell/step1_qc.sh.sign" ]; then
  echo "Step1 QC has been run. Skipping..."; 
else
  echo "Step1 QC has not been run. Running..."; 
  # 调用函数，检查并创建目录中的子目录
  check_and_create_dirs "${step1_outdir}"
  # 调用step1.sh脚本, 进行fastqc质控
  fastqc_dir=$(jq -r '.fastqc' ${soft_file})
  scripts_dir=$(jq -r '.scripts' ${soft_file})
  fastqc_cores=$(jq -r '.fastqc' ${cuttag_file})
  multiqc=$(jq -r '.multiqc' ${soft_file})
  bash ${scripts_dir}/step1_qc.sh  ${input_file} ${step1_outdir} ${fastqc_dir} ${fastqc_cores} ${multiqc}
fi

#  Step2 
step2_outdir=${outdir}/Step2_cutadapt
#  判断是否存在 shell/step2_cutadapt.sign文件，如果存在，则跳过
if [ -f "${step2_outdir}/shell/step2_cutadapt.sh.sign" ]; then
  echo "Step2 Cutadapt has been run. Skipping..."; 
else
  echo "Step2 Cutadapt has not been run. Running..."; 
  # 调用函数，检查并创建目录中的子目录
  check_and_create_dirs "${step2_outdir}"
  # 调用step2.sh脚本, 进行cutadapt质控
  cutadapt_dir=$(jq -r '.cutadapt' ${soft_file})
  cutadapt_cores=$(jq -r '.cutadapt' ${cuttag_file})
  bash ${scripts_dir}/step2_cutadapt.sh  ${input_file} ${step2_outdir}${cutadapt_dir} ${cutadapt_cores}
fi

#  Step3 
step3_outdir=${outdir}/Step3_aligment
#  判断是否存在 shell/step3_aligment.run.sign文件，如果存在，则跳过
if [ -f "${step3_outdir}/shell/step3_aligment.sh.sign" ]; then
  echo "Step3 Aligment has been run. Skipping..."; 
else
  echo "Step3 Aligment has not been run. Running..."; 
  # 调用函数，检查并创建目录中的子目录
  check_and_create_dirs "${step3_outdir}"

  # 制作一个Step3的输入文件
  sed 's#/1.fq.gz/1_val_1.fq.gz#' |  's#/2.fq.gz/2_val_2.fq.gz#' ${input_file}  > \
    ${step3_outdir}/input/Step3.input
  # 调用step3.sh脚本, 进行aligment比对
  bowtie2_dir=$(jq -r '.bowtie2' ${soft_file})
  bowtie2_cores=$(jq -r '.bowtie2' ${cuttag_file})
  ref_dir=$(jq -r '.reference' ${cuttag_file})  
  spike_in_ref=$(jq -r '.spike_in_ref' ${cuttag_file})
  bash ${scripts_dir}/step3_aligment.sh  ${step3_outdir}/input/Step3.input ${step3_outdir}/output \
    ${bowtie2_dir} ${bowtie2_cores} ${ref_dir} ${spike_in_ref}
fi





