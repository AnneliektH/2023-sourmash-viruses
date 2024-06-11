# run virsorter to assess viral contigs
rule virsorter2:
    input:
        contigs = "../results/megahit/{ident}.contigs.rename.fa" 
    output:
        check = "../results/check/{ident}.vs.done.txt"
    conda: 
        "virsorter2"
    threads: 12
    shell:
        """
        virsorter run all -w ../results/virsorter2/{wildcards.ident} \
        -i {input.contigs} -d /group/jbemersogrp/databases/virsorter/ \
        --min-length 5000 -j {threads} --min-score 0.5 && touch {output.check}
        """