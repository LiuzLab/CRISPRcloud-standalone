#!/usr/bin/Rscript

argv <- commandArgs(trailingOnly = TRUE)
source("stat.test.R")
source("generate.xlsx.R")
source("conflict.R")
source("util.R")

flog.info("Running analytics scripts.")

f <- argv[1]
exp.type <- argv[2]
stat.test <- argv[3]
base.group <- argv[4]
print(base.group)
flog.info("Step 1 - running statistical test.")
run.stats(file.path(f), stat.test, base.group)
flog.info("Step 2 - running score calculation.")
get.conflict.summary(file.path(f,'stat.test.txt'), file.path(f,'dir.score.Rdata'), file.path(f,'summary.txt'), exp.type, file.path(f), base.group)
flog.info("Step 3 - generating CPTM matrix.")
generate.CPTM(file.path(f,'mapping.txt'), file.path(f,'summary.txt'), file.path(f,'CPTM.txt'))
flog.info("Step 4 - generating QC plots.")
generate.plots(file.path(f,'mapping.txt'), file.path(f,'summary.txt'), file.path(f, 'corr.txt'), file.path(f, 'mds.txt'))
flog.info("Step 5 - generating excel sheet.")
generate.xlsx(file.path(f))

flog.info("Generating the outputs has finished successfully!")

