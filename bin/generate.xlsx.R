generate.xlsx <- function(dir) {
  file.mapping <- file.path(dir, "CPTM.txt")
  file.stat <- file.path(dir, "stat.test.txt")
  file.output <- file.path(dir,"result.xlsx")
  file.dir <- file.path(dir, "dir.score.Rdata")
  df.map <- read.table(file.mapping, header=T, stringsAsFactors=F, row.names=NULL) %>%
    separate(name, c("gene", "sRNAIdx"), sep="_") 

  df.stat <- read.table(file.stat, header=T, stringsAsFactors=FALSE, row.names=NULL) %>%
    separate(row.names, c("gene", "sRNAIdx"), sep="_")

  wb <- createWorkbook()
  
  addWorksheet(wb, "Hypothesis test for each sRNA")
  addWorksheet(wb, "CPTM")
  writeData(wb, sheet = 1, df.stat)
  writeData(wb, sheet = 2, df.map)
  
  load(file.dir)
   
  sheet.num <- 2
  for(g in names(dir.stat)) {
    dir.format <- list()
    sheet.num <- sheet.num + 1
    addWorksheet(wb, sprintf("Dir. score(%s)",g))
    writeData(wb, sheet = sheet.num, dir.stat[[g]])
  }
  saveWorkbook(wb, file= file.output, overwrite = T)
}
