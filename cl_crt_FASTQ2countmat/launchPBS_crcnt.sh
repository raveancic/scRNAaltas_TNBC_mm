#!/bin/bash

# The singularity args "-B /hpcnfs/" it is useful to mount singularity on all the system and therefore to take file from other folder than the one in which has been launched.

# Before remember to acitvate the environmente with source activate /hpcnfs/home/ieo5177/.conda/envs/py3/envs/snakemake


snakemake -s GenerateCountv3.smk  \
-j 99999 \
--use-singularity \
--singularity-args "-B  /hpcnfs/" \
--keep-going \
--directory /hpcnfs/scratch/EO/atlas_mm_scRNA/ \
--configfile /hpcnfs/scratch/EO/atlas_mm_scRNA/config_new.yaml \
--cluster-config /hpcnfs/scratch/EO/atlas_mm_scRNA/cluster.json \
--cluster "qsub -V -S /bin/sh -N {cluster.name} -m ae -M {cluster.mail} -l ncpus={cluster.ncpus} -l mem={cluster.mem}G  -o {cluster.stdout} -e {cluster.stderr} -P {cluster.project_name} -q nocg_workq"
