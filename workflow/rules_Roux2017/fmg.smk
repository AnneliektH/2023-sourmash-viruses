rule do_gather:
    input:
        sig_mh='../results/signatures/{ident}.mh.dna.s{scaled}.zip',
        sig_vs='../results/signatures/{ident}.vs.dna.s{scaled}.zip',
        db = '/home/ntpierce/2023-vsmash/output.refseq69/refseq69_phages.dna-sc{scaled}.zip'
    output:
        txt_mh='../results/gather/{ident}.mh.dna.s{scaled}.k{ksize}.fullgather.txt',
        csv_mh='../results/gather/{ident}.mh.dna.s{scaled}.k{ksize}.fullgather.csv',
        txt_vs='../results/gather/{ident}.vs.dna.s{scaled}.k{ksize}.fullgather.txt',
        csv_vs='../results/gather/{ident}.vs.dna.s{scaled}.k{ksize}.fullgather.csv',
    shell: """
        sourmash gather -k {wildcards.ksize} {input.sig_mh} {input.db} \
        --scaled {wildcards.scaled} -o {output.csv_mh} \
        --threshold-bp=0 > {output.txt_mh} && \
        sourmash gather -k {wildcards.ksize} {input.sig_vs} {input.db} \
        --scaled {wildcards.scaled} -o {output.csv_vs} \
        --threshold-bp=0 > {output.txt_vs}   
    """

rule do_gather_prot:
    input:
        sig_mh='../results/signatures/{ident}.mh.prot.s{scaled}.zip',
        sig_vs='../results/signatures/{ident}.vs.prot.s{scaled}.zip',
        db = '/home/ntpierce/2023-vsmash/output.refseq69/refseq69_phages.protein-sc{scaled}.zip'
    output:
        txt_mh='../results/gather/{ident}.mh.prot.s{scaled}.k{ksize}.fullgather.txt',
        csv_mh='../results/gather/{ident}.mh.prot.s{scaled}.k{ksize}.fullgather.csv',
        txt_vs='../results/gather/{ident}.vs.prot.s{scaled}.k{ksize}.fullgather.txt',
        csv_vs='../results/gather/{ident}.vs.prot.s{scaled}.k{ksize}.fullgather.csv',
    shell: """
        sourmash gather -k {wildcards.ksize} --protein {input.sig_mh} {input.db} \
        --scaled {wildcards.scaled} -o {output.csv_mh} \
        --threshold-bp=0 > {output.txt_mh} && \
        sourmash gather -k {wildcards.ksize} --protein {input.sig_vs} {input.db} \
        --scaled {wildcards.scaled} -o {output.csv_vs} \
        --threshold-bp=0 > {output.txt_vs}
    """

rule do_gather_read:
    input:
        sig_read='../results/signatures/{ident}.dna.s{scaled}_reads.zip',
        db = '/home/ntpierce/2023-vsmash/output.refseq69/refseq69_phages.dna-sc{scaled}.zip'
    output:
        txt_read='../results/gather/{ident}.read.dna.s{scaled}.k{ksize}.fullgather.txt',
        csv_read='../results/gather/{ident}.read.dna.s{scaled}.k{ksize}.fullgather.csv',
    shell: """
        sourmash gather -k {wildcards.ksize} {input.sig_read} {input.db} \
        --scaled {wildcards.scaled} -o {output.csv_read} \
        --threshold-bp=0 > {output.txt_read}      
    """

rule do_gather_prot_read:
    input:
        sig_read='../results/signatures/{ident}.translate.s{scaled}_reads.zip',
        db = '/home/ntpierce/2023-vsmash/output.refseq69/refseq69_phages.protein-sc{scaled}.zip'
    output:
        txt_read='../results/gather/{ident}.read.translate.s{scaled}.k{ksize}.fullgather.txt',
        csv_read='../results/gather/{ident}.read.translate.s{scaled}.k{ksize}.fullgather.csv',
    shell: """
        sourmash gather -k {wildcards.ksize} --protein {input.sig_read} {input.db} \
        --scaled {wildcards.scaled} -o {output.csv_read} \
        --threshold-bp=0 > {output.txt_read}      
    """
# do taxonomy
rule tax_gather:
    input:
        csv='../results/gather/{fullgather}.fullgather.csv',
    output:
        taxout = '../results/tax/{fullgather}.tax.csv'
    shell: """
        sourmash tax metagenome -g {input.csv} -t {TAXDB} > {output.taxout}
    """
