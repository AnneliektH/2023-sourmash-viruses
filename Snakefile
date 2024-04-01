# imports
import os
import pandas as pd

# Define samples
SAMPLES, = glob_wildcards('ictv/reads/10M/{ident}_R1.fq.gz')

wildcard_constraints:
    sample='\w+',

rule all:
    input:
        expand('ictv/reads/10M/check/{ident}.mh.done.txt', ident=SAMPLES),
        expand('ictv/signatures/{ident}.dna.s100.sig.gz', ident=SAMPLES),
        expand('ictv/signatures/{ident}.translate.s100.sig.gz', ident=SAMPLES),  
        expand('ictv/reads/10M/check/{ident}.vs.done.txt', ident=SAMPLES)
        
rule sketch_reads:
    input:
       fq1='ictv/reads/10M/{ident}_R1.fq.gz',
       fq2='ictv/reads/10M/{ident}_R2.fq.gz',
    output:
        sig_dna='ictv/signatures/{ident}.dna.s100.sig.gz',
        sig_prot='ictv/signatures/{ident}.translate.s100.sig.gz'
    conda: 
        "branchwater"
    threads: 6
    shell:
        """
        module load parallel
        sourmash sketch dna \
        {input.fq1} {input.fq2} -p abund,k=21,scaled=100,k=15,scaled=100 \
        -o {output.sig_dna} --name {wildcards.ident} | parallel -j {threads} && \
        sourmash sketch translate \
        {input.fq1} {input.fq2} -p abund,k=7,scaled=100,k=10,scaled=100 \
        -o {output.sig_prot} --name {wildcards.ident} | parallel -j {threads}
        """

rule assemble:
# works
    input:
       fq1='ictv/reads/10M/{ident}_R1.fq.gz',
       fq2='ictv/reads/10M/{ident}_R2.fq.gz',
    output:
        contigs='ictv/reads/10M/{ident}.contigs.fa',
        check = "ictv/reads/10M/check/{ident}.mh.done.txt",
    conda: 
        "megahit"
    params:
        output_folder = "ictv/reads/10M",
        output_temp = "ictv/megahit_temp"
    threads: 6
    shell:
        """
        mkdir -p ictv/megahit_temp/
   
        # megahit does not allow force overwrite, so each assembly needs to take place in it's own directory. 
        megahit -1 {input.fq1} -2 {input.fq2} \
        -t {threads} --continue --k-min 27 --min-contig-len 1000 -m 0.095 \
        --out-dir {params.output_temp}/{wildcards.ident} \
        --out-prefix {wildcards.ident} && \
        mv {params.output_temp}/{wildcards.ident}/{wildcards.ident}.contigs.fa \
        {params.output_folder} && touch {output.check}
        """

# rename found vOTUs
rule bbmap_rename:
    input: 
        check = "ictv/reads/10M/check/{ident}.mh.done.txt",
        contigs = "ictv/reads/10M/{ident}.contigs.fa"
    output: 
        contigs = "ictv/reads/10M/{ident}.contigs.rename.fa"
    conda: 
        "bbmap"
    shell:
        """
        rename.sh in={input.contigs} \
        out={output.contigs} prefix={wildcards.ident}_contig_
        """

rule virsorter2:
    input:
        contigs = "ictv/reads/10M/{ident}.contigs.rename.fa" 
    output:
        check = "ictv/reads/10M/check/{ident}.vs.done.txt"
    conda: 
        "virsorter2"
    threads: 12
    shell:
        """
        virsorter run all -w ictv/reads/10M/virsorter2/{wildcards.ident} \
        -i {input.contigs} \
        --min-length 5000 -j {threads} --min-score 0.5 && touch {output.check}
        """

rule protein prediction:

rule sketch_protein:

rule genomad:

rule get_fq_headers:
# works
    input:
        fq='ictv/reads/10M/{ident}_R1.fq.gz',
    output:
        txt='ictv/reads/10M/{ident}.header.txt'
    shell: """
        zcat {input.fq} | grep '^@' > {output.txt}
    """

