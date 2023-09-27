rule sourmash_sig:
    input:
        fq="test_dataset_Roux2017/raw_reads/{sample}_Reads_raw.fastq.gz"
    output:
        sig = "signatures/{sample}.{k}.dna.zip"
    log:
        "logs/signature/{sample}.{k}.log"
    conda: 
        "sourmash"
    shell:
        """
        sourmash sketch dna -p \
        k={wildcards.k},scaled=100,abund \
        {input.fq} --name {wildcards.sample} \
        -o {output.sig}
        """