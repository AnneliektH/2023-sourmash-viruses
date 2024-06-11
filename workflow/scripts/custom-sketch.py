#! /usr/bin/env python
import sourmash
import screed
import sys
import argparse

from sourmash import sourmash_args


def collect_records_in_batch(screed_iter):
    "Collect records with same prefix style => return in batches"
    # note: generator function

    # collect things with same prefix: Sample_10_contig_9_...

    prefix = None
    batch = []
    for record in screed_iter:
        name = record.name
        record_prefix = name.split('_', 4)
        record_prefix = '_'.join(record_prefix[:4])

        if prefix is None:
            prefix = record_prefix

        if prefix == record_prefix:
            print('collecting:', record_prefix, name)
            batch.append(record)
        else: # if prefix != record_prefix:
            # return this batch, reset
            yield prefix, batch
            prefix = record_prefix
            batch = [record]

    # return last batch
    if prefix:
        yield prefix, batch


def main():
    p = argparse.ArgumentParser()
    p.add_argument('protein_seqs', nargs='+')
    p.add_argument('-k', '--ksize', type=int, default=7)
    p.add_argument('--scaled', type=int, default=100)
    p.add_argument('-o', '--output', required=True)
    args = p.parse_args()

    mh_template = sourmash.MinHash(n=0, ksize=args.ksize, scaled=args.scaled,
                                   is_protein=True)

    with sourmash_args.SaveSignaturesToLocation(args.output) as save_sigs:
        for filename in args.protein_seqs:
            screed_iter = screed.open(filename)
            for name, list_of_records in collect_records_in_batch(screed_iter):
                print(f'consumed size={len(list_of_records)} batch.')
                mh = mh_template.copy_and_clear()
                for record in list_of_records:
                    mh.add_protein(record.sequence)
                ss = sourmash.SourmashSignature(mh, name=name)

                save_sigs.add(ss)

        print(f"saved {len(save_sigs)} sketches to '{args.output}")


if __name__ == '__main__':
    sys.exit(main())
