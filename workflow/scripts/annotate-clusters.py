import os, sys
import csv
import argparse

import sourmash
from sourmash.tax import tax_utils
from sourmash.logging import notify, error



def main(args):
    """
    Annotate cluster results with LCA taxonomic lineage.
    """

    with sourmash.sourmash_args.FileInputCSV(args.taxonomy_csv) as r:
        header = r.fieldnames
        # check for empty file
        if not header:
            notify(f"Cannot read from '{args.taxonomy_csv}'. Is file empty?")
            sys.exit(-1)

        # check cluster file
        if 'query_name' not in header or 'lineage' not in header:
            notify(f"Either 'query_name' or 'lineage' column missing. Is {args.taxonomy_csv} an annotated gather file?")
            sys.exit(-1)

        tax_assign = {}

        # Iterate over each row in the reader
        for row in r:
            # Add the mapping to the tax_assign dictionary
            ident = sourmash.tax.tax_utils.get_ident(row['query_name'])
            tax_assign[ident] = row['lineage']

    # Check for a column we can use to find lineage information:
    with sourmash.sourmash_args.FileInputCSV(args.cluster_csv) as r:
        header = r.fieldnames
        # check for empty file
        if not header:
            notify(f"Cannot read from '{args.cluster_csv}'. Is file empty?")
            sys.exit(-1)

        # check cluster file
        if 'nodes' not in header:
            notify(f"no 'nodes' column. Is this {args.cluster_csv} cluster file?")
            sys.exit(-1)

        # make output file for this input
        out_base = os.path.basename(args.cluster_csv.rsplit(".csv")[0])
        this_outfile = os.path.join(args.output_dir, out_base + ".with-lineages.csv")
        out_header = header + ["lineage"]

        with sourmash.sourmash_args.FileOutputCSV(this_outfile) as out_fp:
            w = csv.DictWriter(out_fp, out_header)
            w.writeheader()

            n = 0
            n_missed = 0
            rows_missed = 0
            for n, row in enumerate(r):
                # find annotation for each node in the cluster, then take LCA.
                cluster_annot = set()
                nodes = row['nodes'] # should be the list of queries in this cluster
                for node in nodes.split(';'):
                    # find lineage and write annotated row
                    lineage=None
                    lin = tax_assign.get(node)
                    if lin:
                        if args.lins:
                            lineage = tax_utils.LINLineageInfo(lineage_str=lin)
                        elif args.ictv:
                            lineage = tax_utils.ICTVRankLineageInfo(lineage_str=lin)
                        else:
                            lineage = tax_utils.RankLineageInfo(lineage_str=lin)
                        # add match lineage to cluster_annot
                        cluster_annot.add(lineage)
                    else:
                        n_missed += 1

                # get LCA of the node taxonomic assignments
                if len(cluster_annot) == 0:
                    rows_missed +=1
                    continue
                elif len(cluster_annot) > 1:
                    lin_tree = sourmash.tax.tax_utils.LineageTree(cluster_annot)
                    lca_lin = lin_tree.find_lca()
                else:
                    lca_lin = (list(cluster_annot)[0], 0)

                # ARGH, LineageTree is designed to work with original lineage tuples too, so returns a tuple result, not a LineageInfo class. Convert back.
                # to do: modify LineageTree to just work with LineageInfo classes, and always return a LineageInfo class.
                lca_lineage = lca_lin[0]
                lineage = ""
                if lca_lineage!= ():
                    if args.lins:
                        if not isinstance(lca_lineage, tax_utils.LINLineageInfo):
                            lca_lineage = tax_utils.LINLineageInfo(lineage=lca_lineage)
                    elif args.ictv:
                        if not isinstance(lca_lineage, tax_utils.ICTVRankLineageInfo):
                            lca_lineage = tax_utils.ICTVRankLineageInfo(lineage=lca_lineage)
                    else:
                        if not isinstance(lca_lineage, tax_utils.RankLineageInfo):
                            lca_lineage = tax_utils.RankLineageInfo(lineage=lca_lineage)
                    # display lineage
                    lineage = lca_lineage.display_lineage()

                row["lineage"] = lineage

                # write row to output
                w.writerow(row)

            rows_annotated = (n + 1) - rows_missed
            if n_missed:
                notify(f"Missed {n_missed} taxonomic assignments during annotation.")
            if not rows_annotated:
                notify(
                    f"Could not annotate any rows from '{args.cluster_csv}'."
                )
                sys.exit(-1)
            else:
                notify(
                    f"Annotated {rows_annotated} of {n+1} total rows from '{args.cluster_csv}'."
                )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Annotate cluster results with LCA taxonomic lineage.")
    parser.add_argument("cluster_csv", help="Path to the cluster CSV file.")
    parser.add_argument("-t", "--taxonomy_csv", help="Path to the taxonomy CSV file.")
    parser.add_argument("-o", "--output-dir", help="Output directory for annotated CSV files.", default=".")
    parser.add_argument("-f", "--force", help="Force loading taxonomic assignments.", action="store_true")
    parser.add_argument("--lins", help="Use LIN taxonomic assignments.", action="store_true")
    parser.add_argument("--ictv", help="Use ICTV taxonomic assignments.", action="store_true")
    args = parser.parse_args()
    main(args)