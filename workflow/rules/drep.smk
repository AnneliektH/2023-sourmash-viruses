rule split_contigs:
    input:
        contigs_mh = "../results/megahit/{ident}.contigs.rename.fa", 
        contigs_vs = "../results/vir_contigs/{ident}.fa"
    output:
        check_mh = "../results/drep/check/{ident}.mh.split.done.txt", 
        check_vs = "../results/drep/check/{ident}.vs.split.done.txt"
    conda: 
        "bbmap"
    threads: 1
    shell:
        """
        demuxbyname.sh \
        in={input.contigs_mh} \
        out=../results/megahit/split/{wildcards.ident}/{wildcards.ident}_%.fa \
        header=t && touch {output.check_mh} && \
        demuxbyname.sh \
        in={input.contigs_vs} \
        out=../results/virsorter2/split/{wildcards.ident}/{wildcards.ident}_%.fa \
        header=t && touch {output.check_vs} 
        """

rule drep:
    input:
        check_mh = "../results/drep/check/{ident}.mh.split.done.txt", 
        check_vs = "../results/drep/check/{ident}.vs.split.done.txt"
    output:
        drep_mh = "../results/drep/check/{ident}.mh.done.txt", 
        drep_vs = "../results/drep/check/{ident}.vs.done.txt"
    conda: 
        "drep"
    threads: 10
    shell:
        """
        dRep dereplicate \
        ../results/drep/mh/{wildcards.ident} \
        --S_algorithm ANImf \
        --ignoreGenomeQuality \
        -sa 0.95 -nc 0.85 \
        -g ../results/megahit/split/{wildcards.ident}/*.fa -p {threads} \
        && touch {output.drep_mh}
        dRep dereplicate \
        ../results/drep/vs/{wildcards.ident} \
        --S_algorithm ANImf \
        --ignoreGenomeQuality \
        -sa 0.95 -nc 0.85 \
        -g ../results/virsorter2/split/{wildcards.ident}/*.fa -p {threads} \
        && touch {output.drep_vs}
        """
rule cat_contigs:
    input:
        drep_mh = "../results/drep/check/{ident}.mh.done.txt", 
        drep_vs = "../results/drep/check/{ident}.vs.done.txt"
    output:
        contigs_mh = "../results/drep/{ident}_mh.fa",
        contigs_vs = "../results/drep/{ident}_vs.fa"
    threads: 1
    shell:
        """
        cat ../results/drep/mh/{wildcards.ident}/dereplicated_genomes/*.fa > {output.contigs_mh} && \
        cat ../results/drep/vs/{wildcards.ident}/dereplicated_genomes/*.fa > {output.contigs_vs}
        """