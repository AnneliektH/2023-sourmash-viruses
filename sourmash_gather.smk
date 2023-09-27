rule sourmash_gather:
    input:
        sig="signatures/{sample}.{k}.{scaled}.dna.zip"
    output:
        result_csv = "gather/{k}/{sample}-x-RS219-scaled_{scaled}.gather.csv"
    log:
        "logs/gather/{sample}.{k}.{scaled}.log"
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather --threshold-bp 0 \
        {input.sig} \
        RefSeq_v219.sig \
        -k {wildcards.k} --scaled {wildcards.scaled} \
        -o {output.result_csv}
        """