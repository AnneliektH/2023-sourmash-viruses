# imports
import os
import pandas as pd

include: "sourmash_sig.smk"

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


rule all:
    input:
        expand("signatures/{sample}.{k}.dna.zip", sample=SAMPLES, k=config["k_size"])

# list_all_inputs = [
#     expand(
#         f"signatures/.{sample}.{{k}}.sig", zip, k=config["k_size"], sample=SAMPLES
#         )]

# rule all:
#    input:
#         list_all_inputs