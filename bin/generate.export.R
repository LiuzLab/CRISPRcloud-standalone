#!/usr/bin/Rscript

argv <- commandArgs(trailingOnly = TRUE)
lib.path <- argv[1]
source(file.path(lib.path,"stat.test.R"))
source(file.path(lib.path,"generate.xlsx.R"))
source(file.path(lib.path,"conflict.R"))
source(file.path(lib.path,"util.R"))

flog.info("Running analytics scripts.")

input.path <- argv[2]
output.path <- argv[3]
exp.type <- argv[4]
stat.test <- argv[5]
base.group <- argv[6]
flog.info("Step 1 - running statistical test.")
run.stats(file.path(input.path), file.path(output.path), stat.test, base.group)
flog.info("Step 2 - running score calculation.")
get.conflict.summary(file.path(output.path,'stat.test.txt'), file.path(output.path,'dir.score.Rdata'), file.path(input.path,'summary.txt'), exp.type, file.path(output.path), base.group)
flog.info("Step 3 - generating CPTM matrix.")
generate.CPTM(file.path(input.path,'mapping.txt'), file.path(input.path,'summary.txt'), file.path(output.path,'CPTM.txt'))
flog.info("Step 4 - generating QC plots.")
generate.plots(file.path(input.path,'mapping.txt'), file.path(input.path,'summary.txt'), file.path(output.path, 'corr.txt'), file.path(output.path, 'mds.txt'))
flog.info("Step 5 - generating excel sheet.")
generate.xlsx(file.path(output.path))

flog.info("Generating the outputs has finished successfully!")

