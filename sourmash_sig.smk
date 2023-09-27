rule sourmash_sig:
    input:
        fq="test_dataset_Roux2017/raw_reads/{sample}_Reads_raw.fastq.gz"
    output:
        sig = "signatures/{sample}.{k}.{scaled}.dna.zip"
    log:
        "logs/signature/{sample}.{k}.{scaled}.log"
    conda: 
        "sourmash"
    shell:
        """
        sourmash sketch dna -p \
        k={wildcards.k},scaled={wildcards.scaled},abund \
        {input.fq} --name {wildcards.sample} \
        -o {output.sig}
        """