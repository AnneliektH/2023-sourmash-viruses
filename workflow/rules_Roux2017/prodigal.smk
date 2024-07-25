# predict proteins
rule protein_prediction:
    input:
        contigs_vir = "../results/vir_contigs/{ident}.fa",
        contigs_mh =  "../results/megahit/{ident}.contigs.rename.fa",
    output:
        prot_vir = "../results/vir_contigs/{ident}.faa",
        prot_mh = "../results/megahit/{ident}.faa"
    conda: 
        "prodigal"
    threads: 1
    shell:
        """
        prodigal -i {input.contigs_vir} -a {output.prot_vir} -p meta -q && \
        prodigal -i {input.contigs_mh} -a {output.prot_mh} -p meta -q
        """
# # predict proteins
# rule protein_prediction_drep:
#     input:
#         drep_mh = "../results/drep/{ident}_mh.fa", 
#         drep_vs = "../results/drep/{ident}_vs.fa"
#     output:
#         prot_vir = "../results/drep/{ident}_vs.faa",
#         prot_mh = "../results/drep/{ident}_mh.faa"
#     conda: 
#         "prodigal"
#     threads: 1
#     shell:
#         """
#         prodigal -i {input.drep_mh} -a {output.prot_mh} -p meta -q && \
#         prodigal -i {input.drep_vs} -a {output.prot_vir} -p meta -q
#         """
