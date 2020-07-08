# shell.prefix("set -eo pipefail; echo BEGIN at $(date); ")
# shell.suffix("; exitstat=$?; echo END at $(date); echo exit status was $exitstat; exit $exitstat")

import os
# import subprocess

# For fancy configuration file also for the cluster look at https://github.com/crazyhottommy/pyflow-cellranger/blob/master/Snakefile
# Name of the config file
configfile: "config_new.yaml"

# Import the file GTF and FASTA
link_fa=config['link_fa']
file_fa=config['file_fa']
link_gtf=config['link_gtf']
file_gtf=config['file_gtf']

# Load the CLUSTER and SAMPLES .json
CLUSTER = json.load(open(config['CLUSTER_JSON']))
FILES_SAMPLE = json.load(open(config['SAMPLES_JSON']))

# Extract the sammples
SAMPLES = sorted(FILES_SAMPLE.keys())

# Assign the folder for donwload log Snakemake creates the folder if they do no exist
LOG_FA='dwn_log/'+'log_'+file_fa
LOG_GTF='dwn_log/'+'log_'+file_gtf

# Assign the folder where to create the file that terminates the process and can be inserted in rule all
FILT_REF_CELLRANG="ref_cellranger/"+file_gtf+".filteredcreated.stamp"
FILT_REF_INDEX="ref_cellranger/"+file_fa+".indexed.stamp"

# Assign the folder where to create the file that terminates the process and can be inserted in rule all
COUNT = []
for sample in SAMPLES:
	COUNT.append("count_stamps/" + sample + ".end")
#
# Empty list
TARGETS = []

# Append all the file that will be the output
TARGETS.append(LOG_FA)
TARGETS.append(LOG_GTF)
TARGETS.append(FILT_REF_CELLRANG)
TARGETS.append(FILT_REF_INDEX)
TARGETS.extend(COUNT)

# Define a rule that is local to all
localrules: all
rule all:
    input: TARGETS

# Define the rule for download
rule dwn_ref:
    message:
        "Downloading the GTF and FASTA sequences"
    output:
        dwn_fa=temp(file_fa+".fa.gz"),
        dwn_gtf=temp(file_gtf+".gtf.gz"),
        log_dwn_fa='dwn_log/'+'log_'+file_fa,
        log_dwn_gtf='dwn_log/'+'log_'+file_gtf,
        file_fa="ref/"+file_fa+".fa",
        file_gtf="ref/"+file_gtf+".gtf"
    shell:
        """
        wget -o {output.log_dwn_gtf} {link_gtf}{output.dwn_gtf}
        gunzip -c {output.dwn_gtf} > {output.file_gtf}
        wget -o {output.log_dwn_fa} {link_fa}{output.dwn_fa}
        gunzip -c {output.dwn_fa} > {output.file_fa}
        """

#Create the rule to filter the genes
rule cr_filter_ref:
    message:
        "Cell Ranger performing the filtering..."
    singularity:
        config['singularity_img']
    input:
        "ref/"+file_gtf+".gtf"
    output:
        filtered_gtf="ref/"+file_gtf+".filtered.gtf",
        endfile_filter="ref_cellranger/"+file_gtf+".filteredcreated.stamp"
    shell:
        """
        cellranger mkgtf {input} {output.filtered_gtf} \
        --attribute=gene_biotype:protein_coding \
        --attribute=gene_biotype:lincRNA \
        --attribute=gene_biotype:antisense \
        --attribute=gene_biotype:IG_LV_gene \
        --attribute=gene_biotype:IG_V_gene \
        --attribute=gene_biotype:IG_V_pseudogene \
        --attribute=gene_biotype:IG_D_gene \
        --attribute=gene_biotype:IG_J_gene \
        --attribute=gene_biotype:IG_J_pseudogene \
        --attribute=gene_biotype:IG_C_gene \
        --attribute=gene_biotype:IG_C_pseudogene \
        --attribute=gene_biotype:TR_V_gene \
        --attribute=gene_biotype:TR_V_pseudogene \
        --attribute=gene_biotype:TR_D_gene \
        --attribute=gene_biotype:TR_J_gene \
        --attribute=gene_biotype:TR_J_pseudogene \
        --attribute=gene_biotype:TR_C_gene
		touch {output.endfile_filter}
        """

# Create the rule to index the filter
rule cr_create_index:
    message:
        "Cell Ranger performing the indexing..."
    singularity:
        config['singularity_img']
    input:
        filt_gtf="ref/"+file_gtf+".filtered.gtf",
        file_fa_2index="ref/"+file_fa+".fa"
    output:
        folder_ref=directory(config['ref_folder']),
        endfile_index="ref_cellranger/"+file_fa+".indexed.stamp"
    params:
        version="3.1.0"
    shell:
        """
        cellranger mkref\
		--genome={output.folder_ref}\
		--fasta={input.file_fa_2index}\
		--genes={input.filt_gtf}\
		--nthreads=12\
		--ref-version={params.version}
		touch {output.endfile_index}
        """

# Function to call the samples in the wildcards taken from here https://github.com/crazyhottommy/pyflow-cellranger/blob/master/Snakefile
def get_fastq_per_sample(wildcards):
	fastqs = []
	for id in FILES_SAMPLE[wildcards.sample].keys():
		fastqs.append(FILES_SAMPLE[wildcards.sample][id])
	return ",".join(fastqs)

rule cr_count:
    message:
        "Cell Ranger is performing the count..."
    singularity:
        config['singularity_img']
    input:
        fold_transcriptome=config['ref_folder']
    output:
        "count_stamps/{sample}.end"
    params:
        fastq=get_fastq_per_sample,
        cells=config['expected_numb_cells'],
        core=config['loc_cores'],
        job="local",
        mem=config['ram_used'],
        mempercore=config['mem_per_core'],
		# Need to generate an output folder because during the processing Cell Ranger generates huge file that can be too heavy for the folder in which you are running the piepeline
        out_folder=config['out_cr_count'],
        home_folder=config['home_folder']
    # log:
    shell:
        """
		cd {params.out_folder}
        cellranger count\
        --id={wildcards.sample}\
        --transcriptome={params.home_folder}{input.fold_transcriptome}\
        --fastqs={params.fastq}\
        --sample={wildcards.sample}\
        --expect-cells={params.cells}\
        --jobmode={params.job}\
        --localcores={params.core}\
        --localmem={params.mem}\
        --mempercore={params.mempercore}
        touch {params.home_folder}{output}
        """
