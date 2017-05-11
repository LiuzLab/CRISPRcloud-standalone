When a user wants to customize a statistical test or has to handle a low-quality dataset, the standalone version of CRISPRcloud pipeline will be a good option to deal with that requirements. This pipeline is built with Snakemake (Köster and Rahmann, 2012), and it can be easily customized by a user. We describe how to use the pipeline and show a way to add a custom test in this section.
1.    Installation
The pipeline has tested on MacOS and Ubuntu successfully, and the following applications must be installed before using it.
* Git: https://git-scm.com/
* R: https://cran.r-project.org/
* Python3: https://www.python.org/download/releases/3.0/
* Snakemake: http://snakemake.readthedocs.io/en/stable/
First, run the below command on the terminal. A sudo/root account will need to install additional R packages.
git clone https://github.com/hyunhwaj/CRISPRcloud-standalone
./install_packages.sh
2.    Preparing dataset

3.    Edit configurations in Snakemake

4.    Run pipeline
Snakemake
Snakemake also allows multi-core processing with the "-ncores" parameter.
Snakemake –ncores=4
