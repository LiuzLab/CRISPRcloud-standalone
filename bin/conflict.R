run.conflict.summary <- function(df.test, column, exp.type) {
  df.test <- df.test[,column]
  df.test$sRNA <- rownames(df.test)
  df.test <- df.test %>% 
    separate(sRNA, c("gene", "index"), sep="_")
  
  if(exp.type == "dropout") {
    df.ret <- data.frame(gene=df.test$gene,
                         pval = df.test[,2],
                         fc = df.test[,1])
    df.ret <- df.ret %>%
      mutate(dir=c("D","N","E")[sign(fc) * (pval<0.05)+2])
    df.dir <- df.ret %>% group_by(gene) %>% count(dir) %>% spread(dir,n)
    df.dir[is.na(df.dir)] <- 0
    
    for(dir in c("D", "N", "E")) {
      if(!(dir %in% colnames(df.dir))) {
        df.dir[[dir]] <- 0
      }
    }
    
    df.score <- df.ret %>% group_by(gene) %>% 
      summarise(fc=mean(fc), 
                total=n(),
                pval=pchisq(-2*sum(log(pval)), n()*2, lower.tail=F))
    df.score <- df.score %>% left_join(df.dir, by="gene") %>%
      mutate(ov_exp = E, dn_exp = D) %>%
      mutate(dir_score = pmax(ov_exp,dn_exp) / pmax(1, ov_exp+dn_exp),
             hit_ratio = pmax(ov_exp,dn_exp) / total)
    df.score$fdr <- p.adjust(df.score$pval, method="BH")
    df.score <- df.score %>%
      select(gene, total, ov_exp, dn_exp, dir_score, hit_ratio, fc, pval, fdr)
  }
  else {
    df.ret <- data.frame(gene=df.test$gene,
                         fc1 = df.test[,1],
                         pval1 = df.test[,2],
                         fc2 = df.test[,4],
                         pval2 = df.test[,5])
    
    df.ret <- df.ret %>%
      mutate(dir1=c("D","N","E")[sign(fc1) * (pval1<0.05)+2],
             dir2=c("D","N","E")[sign(fc2) * (pval2<0.05)+2]) %>%
      unite(dir, dir1, dir2, sep="")

    df.dir <- df.ret %>% group_by(gene) %>% count(dir) %>% spread(dir,n)
    df.dir[is.na(df.dir)] <- 0
    
    for(dir in c("DD", "DN", "DE", "ND", "NN", "NE", "ED", "EN", "EE")) {
      if(!(dir %in% colnames(df.dir))) {
        df.dir[[dir]] <- 0
      }
    }

    df.score <- df.ret %>% group_by(gene) %>% 
      summarise(fc1=mean(fc1), 
                fc2=mean(fc2),
                total=n(),
                pval1=pchisq(-2*sum(log(pval1)), n()*2, lower.tail=F),
                pval2=pchisq(-2*sum(log(pval2)), n()*2, lower.tail=F))
    
    df.score <- df.score %>% left_join(df.dir, by="gene") %>%
       mutate(ov_exp = ED+EN+ND, dn_exp = DE+NE+DN) %>%
       mutate(dir_score = pmax(ov_exp,dn_exp) / pmax(1, ov_exp+dn_exp),
              hit_ratio = pmax(ov_exp,dn_exp) / total,
              conflict = (EE+DD) / total ) 
    df.score$fdr1 <- p.adjust(df.score$pval1, method="BH")
    df.score$fdr2 <- p.adjust(df.score$pval2, method="BH")
    df.score <- df.score %>%    
       select(gene, total, ov_exp, dn_exp, 
              dir_score, hit_ratio, conflict, fc1, pval1, fdr1, fc2, pval2, fdr2)
  }
  df.score
  
}

get.conflict.summary <- function(input, output, summary, exp.type, dir.path, t0) {
  df.test <- read.table(input, header=T, stringsAsFactors=FALSE)
  df.summary <- read.table(summary, header=T, sep=",", stringsAsFactors = FALSE)
  groups <- unique(df.summary$group)
  
  groups <- groups[-which(groups==t0)]
  ret <- list()
  if(exp.type == "dropout") {
    for(g in groups) {
      columns <- grep(sprintf("%s.",g), colnames(df.test))
      df.ret <- run.conflict.summary(df.test, columns, exp.type)
      colnames(df.ret)[colnames(df.ret)=="fc"] <- sprintf("%s.AVGFC", g)
      colnames(df.ret)[colnames(df.ret)=="pval"] <- sprintf("%s.PVAL", g)
      colnames(df.ret)[colnames(df.ret)=="fdr"] <- sprintf("%s.FDR", g)
      ret[[g]] <- df.ret
    }
  }
  else {
    comb <- t(combn(groups,2))
    for(i in 1:nrow(comb)) {
      group.a <- comb[i,1]
      group.b <- comb[i,2]
      columns.a <- grep(sprintf("%s.",group.a), colnames(df.test))
      columns.b <- grep(sprintf("%s.",group.b), colnames(df.test))
      df.ret <- run.conflict.summary(df.test, c(columns.a, columns.b), exp.type)
      colnames(df.ret)[colnames(df.ret)=="fc1"] <- sprintf("%s.AVGFC", group.a)
      colnames(df.ret)[colnames(df.ret)=="fc2"] <- sprintf("%s.AVGFC", group.b)
      colnames(df.ret)[colnames(df.ret)=="pval1"] <- sprintf("%s.PVAL", group.a)
      colnames(df.ret)[colnames(df.ret)=="pval2"] <- sprintf("%s.PVAL", group.b)
      colnames(df.ret)[colnames(df.ret)=="fdr1"] <- sprintf("%s.FDR", group.a)
      colnames(df.ret)[colnames(df.ret)=="fdr2"] <- sprintf("%s.FDR", group.b)
      ret[[sprintf("%s_%s", group.a, group.b)]] <- df.ret
    }
  }
  dir.stat <- ret
  save(dir.stat, file=output)
  
  for(s in names(dir.stat)) {
    fname <- sprintf("dir.score_%s.csv", s)
    df.out <- dir.stat[[s]]
    print(df.out)
    write.csv(df.out, file=file.path(dir.path, fname), row.names=F)
  }
}

