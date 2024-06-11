# bbmap rules
# rename the viral contigs
rule bbmap_rename_viral:
    input: 
        check = "../results/check/{ident}.vs.done.txt"
    output: 
        contigs = "../results/vir_contigs/{ident}.fa"
    conda: 
        "bbmap"
    shell:
        """
        rename.sh in=../results/virsorter2/{wildcards.ident}/final-viral-combined.fa \
        out={output.contigs} prefix={wildcards.ident}_viral 
        """

# rename assembled contigs
rule bbmap_rename:
    input: 
        check = "../results/check/{ident}.mh.done.txt",
        contigs = "../results/megahit/{ident}.contigs.fa"
    output: 
        contigs = "../results/megahit/{ident}.contigs.rename.fa"
    conda: 
        "bbmap"
    shell:
        """
        rename.sh in={input.contigs} \
        out={output.contigs} prefix={wildcards.ident}_contig_
        """
