# imports
import os
import pandas as pd

include: "sourmash_sig.smk"
include: "sourmash_gather.smk"

# set configfile with samplenames
configfile: "config.yaml"

# Load the metadata file
metadata = pd.read_csv(config['metadata_file_path'], usecols=['Sample'])

# Create a list of run ids
samples = metadata['Sample'].tolist()

# Define samples
SAMPLES = config.get('samples', samples)

wildcard_constraints:
    sample='\w+',


# rule all:
#     input:
#         expand("signatures/{sample}.{k}.{scaled}.dna.zip", sample=SAMPLES, k=config["k_size"], scaled=config["scaled"])

rule all:
    input:
        expand("gather/{k}/{sample}-x-RS219-scaled_{scaled}.gather.csv", 
        sample=SAMPLES, k=config["k_size"], scaled=config["scaled"])

