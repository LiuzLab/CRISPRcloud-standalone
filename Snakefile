SAMPLES, = glob_wildcards("reads/{sample}.fastq.gz")

rule all:
    input:
        expand("reads/{sample}.out", sample=SAMPLES)

rule quant_samples:
    input:
        lib = "libs/yusa_library_small.fa",
        fq = "reads/{sample}.fastq.gz",
    params:
        adapt = "CTTGTGGAAAGGACGAAACACCG",
        err_trim = 0.1,
        mismatch = 0
    output:
        "reads/{sample}.out"
    shell:
        "./bin/quantSamples.py {input.lib} {input.fq} {params.adapt} {params.err_trim} {params.mismatch}" 


