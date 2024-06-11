rule assemble:
# works
    input:
       fq1='../resources/roux2017/sim_reads/{ident}_QC_R1.fastq.gz',
       fq2='../resources/roux2017/sim_reads/{ident}_QC_R2.fastq.gz',
    output:
        contigs='../results/megahit/{ident}.contigs.fa',
        check = "../results/check/{ident}.mh.done.txt",
    conda: 
        "megahit"
    params:
        output_folder = "../results/megahit/",
        output_temp = "../results/megahit_temp"
    threads: 6
    shell:
        """
        mkdir -p ../results/megahit_temp/
   
        # megahit does not allow force overwrite, so each assembly needs to take place in it's own directory. 
        megahit -1 {input.fq1} -2 {input.fq2} \
        -t {threads} --continue --k-min 27 --min-contig-len 1000 -m 0.095 \
        --out-dir {params.output_temp}/{wildcards.ident} \
        --out-prefix {wildcards.ident} && \
        mv {params.output_temp}/{wildcards.ident}/{wildcards.ident}.contigs.fa \
        {params.output_folder} && touch {output.check}
        """