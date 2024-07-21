#/home/syl/Soft/miniconda3/envs/cuttag/bin/R

input=args[1]
output=args[2]

df = read.table(input, sep='\t')
df$V1 = paste0(df$V2, "_", df$V3)

cut_out = paste0(outdir, "/Step2_cutadapt/output/")
for( i in 1:dim(df)[1]){
  df$V4 = paste0(cut_out, df$V1[i], "/", list.files(paste0(cut_out, df$V1[i]),pattern="val_1.fq.gz$"))
  df$V5 = paste0(cut_out, df$V1[i], "/", list.files(paste0(cut_out, df$V1[i]),pattern=".val_2.fq.gz$"))
}

write.table(df, file=paste0(output, "/Step3_aligment/input/input.xls"),sep='\t', quote=F, row.names=F, col.names=F)