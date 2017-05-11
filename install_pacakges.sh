#/usr/bin/bash
cd src
Makefile
cd ..
sudo R -e "install.packages('stringr',repo='https://cloud.r-project.org/')"
sudo R -e "install.packages('ggrepel',repo='https://cloud.r-project.org/')"
sudo R -e "install.packages('RColorBrewer',repo='https://cloud.r-project.org/')"
sudo R -e "install.packages('scales',repo='https://cloud.r-project.org/')"
sudo R -e "install.packages('RJSONIO',repo='https://cloud.r-project.org/')"
sudo R -e "install.packages('futile.logger',repo='https://cloud.r-project.org/')"
sudo R -e "install.packages('openxlsx',repo='https://cloud.r-project.org/')"
sudo R -e "install.packages('tidyverse',repo='https://cloud.r-project.org/')"
sudo R -e "install.packages('https://trac.nbic.nl/ibb/downloads/12', repo=NULL, type='source')"
sudo R -e "source('https://bioconductor.org/biocLite.R');biocLite('DESeq2')"
