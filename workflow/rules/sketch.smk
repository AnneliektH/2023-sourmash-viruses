# various sourmash sketch rules
# sketch megahit contigs directly
rule sketch_mh_contigs:
    input:
       contigs = "../results/megahit/{ident}.contigs.rename.fa"
    output:
        sig_dna='../results/signatures/{ident}.mh.dna.s{scaled}.zip',
    conda: 
        "branchwater"
    threads: 1
    shell:
        """
        sourmash sketch dna \
        {input.contigs} -p abund,k=21,k=15,scaled={wildcards.scaled} \
        -o {output.sig_dna} --name {wildcards.ident}_mh_dna
        """

# sketch virsorter output directly
rule sketch_vs_contigs:
    input:
       contigs = "../results/vir_contigs/{ident}.fa"
    output:
        sig_dna='../results/signatures/{ident}.vs.dna.s{scaled}.zip',
    conda: 
        "branchwater"
    threads: 1
    shell:
        """
        sourmash sketch dna \
        {input.contigs} -p abund,k=21,k=15,scaled={wildcards.scaled} \
        -o {output.sig_dna} --name {wildcards.ident}_vs_dna
        """

# sketch reads into sourmash sigs
rule sketch_reads:
    input:
       fq1='../resources/roux2017/sim_reads/{ident}_QC_R1.fastq.gz',
       fq2='../resources/roux2017/sim_reads/{ident}_QC_R2.fastq.gz',
    output:
        sig_dna='../results/signatures/{ident}.dna.s{scaled}_reads.zip',
        sig_prot='../results/signatures/{ident}.translate.s{scaled}_reads.zip'
    conda: 
        "branchwater"
    threads: 1
    shell:
        """
        sourmash sketch dna \
        {input.fq1} {input.fq2} \
        -p abund,k=21,k=15,scaled={wildcards.scaled} \
        -o {output.sig_dna} --name {wildcards.ident} && \
        sourmash sketch translate \
        {input.fq1} {input.fq2} \
        -p abund,k=7,k=10,scaled={wildcards.scaled} \
        -o {output.sig_prot} --name {wildcards.ident}
        """

rule sketch_protein:
    input:
        prot_vir = "../results/vir_contigs/{ident}.faa",
        prot_mh = "../results/megahit/{ident}.faa"
    output:
        sig_vir='../results/signatures/{ident}.vs.prot.s{scaled}.zip',
        sig_mh='../results/signatures/{ident}.mh.prot.s{scaled}.zip'
    conda: 
        "branchwater"
    threads: 1
    shell:
        """
        sourmash sketch protein {input.prot_vir} -p abund,k=7,k=10,scaled={wildcards.scaled} \
        -o {output.sig_vir} --name {wildcards.ident}_vs_prot && \
        sourmash sketch protein {input.prot_mh} -p abund,k=7,k=10,scaled={wildcards.scaled} \
        -o {output.sig_mh} --name {wildcards.ident}_mh_prot
        """



# sketch predicted proteins
# rule sketch_protein_drep:
#     input:
#         prot_vir = "../results/drep/{ident}_vs.faa",
#         prot_mh = "../results/drep/{ident}_vs.faa"
#     output:
#         sig_vir='../results/signatures/{ident}.vs.prot.s{scaled}.zip',
#         sig_mh='../results/signatures/{ident}.mh.prot.s{scaled}.zip'
#     conda: 
#         "branchwater"
#     threads: 1
#     shell:
#         """
#         sourmash sketch protein {input.prot_vir} -p abund,k=7,k=10,scaled={wildcards.scaled} \
#         -o {output.sig_vir} --name {wildcards.ident}_vs_prot && \
#         sourmash sketch protein {input.prot_mh} -p abund,k=7,k=10,scaled={wildcards.scaled} \
#         -o {output.sig_mh} --name {wildcards.ident}_mh_prot
#         """
# # sketch proteins per contig
# rule sketch_prot_percontig:
#     input:
#         prot_vir = "../results/vir_contigs/{ident}.faa",
#         prot_mh = "../results/megahit/{ident}.faa"
#     output:
#         sig_vir='../results/signatures/contigs/{ident}.vs.prot.s{scaled}.{ksize}.sig.gz',
#         sig_mh='../results/signatures/contigs/{ident}.mh.prot.s{scaled}.{ksize}.sig.gz'
#     conda: 
#         "branchwater"
#     threads: 1
#     shell:
#         """
#         python scripts/custom-sketch.py {input.prot_vir} --scaled {wildcards.scaled} \
#         --ksize {wildcards.ksize} -o {output.sig_vir} && \
#         python scripts/custom-sketch.py {input.prot_vir} --scaled {wildcards.scaled} \
#         --ksize {wildcards.ksize} \
#         -o {output.sig_mh}
#         """