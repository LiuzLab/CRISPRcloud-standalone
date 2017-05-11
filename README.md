When a user wants to customize a statistical test or has to handle a low-quality dataset, the standalone version of CRISPRcloud pipeline will be a good option to deal with that requirements. This pipeline is built with Snakemake (Köster and Rahmann, 2012), and it can be easily customized by a user. We describe how to use the pipeline and show a way to add a custom test in this section.

# 1. Installation
The pipeline has tested on MacOS and Ubuntu successfully, and the following applications must be installed before using it.

* Git: https://git-scm.com/
* R: https://cran.r-project.org/
* Python3: https://www.python.org/download/releases/3.0/
* Snakemake: http://snakemake.readthedocs.io/en/stable/

First, run the below command on the terminal. A sudo/root account will need to install additional R packages.

```
$ git clone https://github.com/hyunhwaj/CRISPRcloud-standalone
$ ./install_packages.sh
```

# 2.Preparing dataset

There are several files which user need to prepare to run the pipeline.

* CRISPR pooled screening RNAseq data: fastq files(or compressed fastq file), recommends to locate "reads" folder.
*  sgRNA library annotations: a fasta file,  in the fasta file of your library, a name of each sgRNA should be formatted as `>genename_<index>`, and `<index>` should be an integer. Otherwise, CRISPRcloud cannot handle your library.  An example of the file is located in "lib" folder (`yusa_library.fa` or `ysa_library_small.fa`), and a git repository https://github.com/hyunhwaj/GeCKOv2_fasta contains GeCKO v2 knockout library for human and mouse.
* Label for each RNAseq data: an example is stored at `data` folder as `label.txt`. Each row represents information of a sample. The first column in the row should be the base name of an RNAseq file without extension (i.e. `CRISPR_SAMPLE_1` should be a value of the column if the filename is `CRISPR_SAMPLE_1.fastq` or `CRISPR_SAMPLE_1.fastq.gz`). The next column should contain a name of a group of the sample, and the value of the last column should be an integer and represent the index number of its replicate. If the same index number appear multiple times in a group, then the corresponded samples are considered as a one replicates in the pipeline.

# 3. Edit configurations in Snakemake

In the `Snakemake` file in the root folder, there are a couple of parameters

# 4. Run pipeline

When the entire setup is done, then run the following command to start the Snakemake pipeline.

```
$ Snakemake
```

Snakemake also allows multi-core processing with the `-ncores` parameter.

```
$ Snakemake –ncores=4
```
