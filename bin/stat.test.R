# Loading the dataset
rep.row<-function(x,n){
  matrix(rep(x,each=n),nrow=n)
}

run.ibb.test <- function( G1, G2, N1, N2 ) {
  library(ibb)
  ibb.test( cbind(G1, G2), cbind( rep.row(N1, NROW(G1)), rep.row(N2, NROW(G2))),
            c(rep("G1", length(N1)), rep("G2", length(N2))), n.threads = 20 )
} 
run.t.test <- function( norm.G1, norm.G2 ) { 
  ret <- list()
  ret$fc <- rowMeans(log2(norm.G2+1)-log2(norm.G1+1))

  norm.G1 <- log10(norm.G1+1)
  norm.G2 <- log10(norm.G2+1)


  if( NCOL( norm.G1 ) <= 2 || NCOL( norm.G2 ) <= 2 ) {
    ret$p.value <- rep(0, NROW(norm.G1));
    ret$p.value[abs(ret$fc)<0.5] <- 1.0
  }
  else {
    ret$p.value <- sapply(1:nrow(norm.G1), function(i) 
    tryCatch(t.test(unlist(norm.G1[i,]), unlist(norm.G2[i,]), paired=T)$p.value, error = function(e) NA))
    ret$p.value[is.nan(ret$p.value)] <- NA
  }
  return(ret)
}

run.deseq2 <- function(cnt.t0, cnt.t1) {
  library(DESeq2)
  ret <- list()
  col.data <- data.frame(condition=rep("T0", ncol(cnt.t0)), row.names = colnames(cnt.t0))
  col.data <- rbind(col.data, data.frame(condition=rep("T1", ncol(cnt.t1)), row.names=colnames(cnt.t1)))
  col.data$condition <- factor(col.data$condition, levels = c("T0", "T1"))
  print(col.data)
  count.matrix <- cbind(cnt.t0, cnt.t1)
  ckCDS <- DESeqDataSetFromMatrix(countData = round(count.matrix),
                                colData = col.data,
                                design =~condition)
  #dds <-DESeq(ckCDS, betaPrior = FALSE, fitType = "mean")
  dds <-DESeq(ckCDS)
  res <- as.data.frame(results(dds))
  #print((res))
  ret$fc <- res$log2FoldChange
  ret$p.value <- res$pvalue
  ret$p.adjust <- res$padj
  return(ret)
}


run.stats <- function(dir, sel.test = "ibb",
                      t0="Base",
                      path.summary="summary.txt",
                      path.mapping="mapping.txt",
                      path.mapping.filtered="mapping.filtered.txt",
                      path.test="stat.test.txt",
                      cut.off = 1) {
  print(t0)
  print(sel.test)
  print(sprintf("running %s", dir))
  norm.const <- 1e7
  rep.row<-function(x,n) matrix(rep(x,each=n),nrow=n)
  file.summary <- file.path(dir,path.summary)
  file.mapping <- file.path(dir,path.mapping)
  file.test  <- file.path(dir,path.test)
  file.mapping.filtered <- file.path(dir,path.mapping.filtered)

  df.map <- read.csv(file.mapping, stringsAsFactors = F)

  df.summary <- read.csv(file.summary, stringsAsFactors = F)
  df.summary$sample.id <- make.names(df.summary$sample.id)
  df.summary$group <- make.names(df.summary$group)
  write.csv(df.summary, file=file.summary, row.names=F)
  print(df.summary)

  GROUP <- unique(df.summary$group)

  symbol <- df.map$sRNA # keep it mind
  row.names(df.map) <- symbol
  df.map <- df.map[,c(-1)]
  take.by.group <- function(sel.col) {
    sapply(GROUP, function(g) {
      filter(df.summary, group==g)[, sel.col]
    }, simplify = F)
  }
  G <- take.by.group("sample.id")
  R <- take.by.group("rep")
  N <- take.by.group("mapped_reads")
  print(head(df.map))
  C <- sapply(G, function(g) df.map[,g, drop = FALSE], simplify = F)
  # nz.row <- which(rowSums(df.map[, G[["Base"]], drop=FALSE ]<cut.off)==0)
  nz.row <- which(rowSums(df.map[,, drop=FALSE ]>=cut.off)>0)
  df.filtered <- df.map[nz.row,]
  write.table(df.filtered, file=file.mapping.filtered, sep="\t")
  test <- list()
  #t0 <- "Base"
  test <- sapply(GROUP[-which(GROUP==t0)], function(t1) {
    common <- intersect(R[[t0]], R[[t1]])
    if(sel.test!="ibb") common <- union(R[[t0]], R[[t1]])
    t0.pos <- which(R[[t0]] %in% common) 
    t1.pos <- which(R[[t1]] %in% common)
    cnt.t0 <- C[[t0]][nz.row,t0.pos, drop=FALSE] 
    cnt.t1 <- C[[t1]][nz.row,t1.pos, drop=FALSE]
    n.t0 <- N[[t0]][t0.pos]
    n.t1 <- N[[t1]][t1.pos]
    norm.t0 <- cnt.t0 / rep.row(n.t0, nrow(cnt.t0)) * norm.const
    norm.t1 <- cnt.t1 / rep.row(n.t1, nrow(cnt.t1)) * norm.const

    if(sel.test=="ibb") {
      ret <- run.ibb.test(cnt.t0, cnt.t1, n.t0, n.t1 )
      ret$fc <- rowMeans(log2(norm.t1+1)-log2(norm.t0+1))
      ret$p.adjust <- p.adjust(ret$p.value, method = "BH")
    }
    else if(sel.test=="logt") {
      ret <- run.t.test(norm.t0, norm.t1)
      ret$fc <- rowMeans(log2(norm.t1+1)-log2(norm.t0+1))
      ret$p.adjust <- p.adjust(ret$p.value, method = "BH")
    }
    else if(sel.test=="deseq2") {
      ret <- run.deseq2(cnt.t0, cnt.t1)
    }
    return(data.frame(fc=ret$fc, p.val=ret$p.value, p.adj=ret$p.adjust))
  }, simplify = F)
  df.ret <- data.frame(test)
  row.names(df.ret) <- symbol[nz.row]
  write.table(df.ret, file=file.test)
}


# 
# run.stats(dir="/tmp/save_430/", sel.test = "deseq2",
#                       t0="Base",
#                       path.summary="summary.txt",
#                       path.mapping="mapping.txt",
#                       path.mapping.filtered="mapping.filtered.txt",
#                       path.test="stat.test.txt",
#                       cut.off = 1)
