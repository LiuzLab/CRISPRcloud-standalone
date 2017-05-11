SAMPLES, = glob_wildcards("reads/{sample}.fastq.gz")

rule all:
    input:
        expand("output/result.xlsx"),

rule quant_samples:
    input:
        lib = "libs/yusa_library_small.fa",
        fq = "reads/{sample}.fastq.gz",
        #fq = expand("reads/{sample}.fastq.gz", sample=SAMPLES)
    params:
        adapt = "CTTGTGGAAAGGACGAAACACCG",
        err_trim = 0.1,
        mismatch = 0
    output:
        "reads/{sample}.out"
    shell:
        "./bin/quantSamples.py {input.lib} {input.fq} {params.adapt} {params.err_trim} {params.mismatch}" 


rule merge_read_count:
    input:
        expand("reads/{sample}.out", sample=SAMPLES),
        "data/label.txt"
    output:
        "data/summary.txt",
        "data/mapping.txt"
    shell:
        "./bin/merge_data.py"

rule run_analysis:
    input:
        "data/summary.txt"
    output:
        "output/result.xlsx"
    params:
        lib_path = "bin/",
        input_path = "data/",
        output_path = "output/",
        study = "dropout",
        base_group = "BASE",
        stat_test = "logt"
    shell:
        "Rscript bin/generate.export.R {params.lib_path} {params.input_path} {params.output_path} {params.study} {params.stat_test} {params.base_group}"
