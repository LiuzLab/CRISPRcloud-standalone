library(ggrepel)
library(RColorBrewer)
library(scales)
library(RJSONIO)
library(MASS)
library(tidyverse)
library(futile.logger)
library(stringr)
library(reshape2)
library(openxlsx)

MDS <- function(m, summary, output.mds.txt) {
  n.sample <- NROW(m) 
  d <- dist(m) # euclidean distances between the rows
  K <- 2
  if (NROW(d) == 1) {
    K <- 1
  }
  fit <- cmdscale(d, eig=TRUE, k=K) # k is the number of dim
  if(length(fit$points)!=0) {
    # plot solution 
    x <- fit$points[,1]
    if( K == 2 ) {
      y <- fit$points[,2]
    }
    else {
      y <- rep(0, length(x))
    }
  }
  else {
    x <- rep(0, n.sample)
    y <- rep(0, n.sample)
  }
  lims <- max(c(abs(x),abs(y)))
  
  data.frame(label=summary[,"sample.id"], group=summary[,"group"], x=x, y=y)
}

rep.row<-function(x,n) matrix(rep(x,each=n),nrow=n)

generate.CPTM <- function(input.map, input.summary, output.CPTM) {
  dat <- read.csv(input.map, header=T, stringsAsFactors=F)
  summary <- read.csv(input.summary, stringsAsFactors=F)
  ngroup <- length( unique(summary$group) )
  summary <- summary[order(summary$sample.id),]
  name <- dat[, 1]
  dat <- dat[, -1]
  dat <- dat[, order(colnames(dat))]
  dat.norm <- dat / rep.row(summary$mapped_reads, NROW(dat)) * 1e7
  dat.norm <- data.frame(name=name, dat.norm)
  write.table(dat.norm, file=output.CPTM, row.names = F) 
}

corr.mat <- function(dat.norm, output.corr.txt) {
  cor(dat.norm, method="pearson")
}

generate.plots <- function(input.map, input.summary, output.corr.txt, output.mds.txt) {
  flog.info("Step A - having a CPTM matrix.")
  dat <- read.csv(input.map, header=T, stringsAsFactors=F)
  summary <- read.csv(input.summary, stringsAsFactors=F)
  ngroup <- length( unique(summary$group) )
  summary <- summary[order(summary$sample.id),]
  dat <- dat[, -1]
  dat <- dat[, order(colnames(dat))]
  dat.norm <- dat / rep.row(summary$mapped_reads, NROW(dat)) * 1e7

  flog.info("Step B - having a correlation matrix.")
  corr <- corr.mat(dat.norm, output.corr.txt)
  write.table(corr, file=output.corr.txt, row.names = F, sep="\t") 

  flog.info("Step C - doing MDS.")
  mds <- MDS(t(dat.norm), summary, output.mds.txt)
  write.table(mds, file=output.mds.txt, sep="\t", row.names = F, quote = F)
}
