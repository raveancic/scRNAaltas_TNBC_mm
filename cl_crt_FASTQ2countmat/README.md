# scRNA count matrix generator with Cell Ranger
### (a Snakemake pipeline)


This pipeline allows to generate the count matrix (and the .bam files) from FASTQ files of scRNA generated with 10Xgenomics. The method is the one applied in [Carpen et al., 2022 *Cell Death Discov*](https://doi.org/10.1038/s41420-022-00893-x). Please if you use this pipeline cite:

Carpen, L., Falvo, P., Orecchioni, S. et al. A single-cell transcriptomic landscape of innate and adaptive intratumoral immunity in triple negative breast cancer during chemo- and immunotherapies. *Cell Death Discov*. 8, 106 (2022). [https://doi.org/10.1038/s41420-022-00893-x](https://doi.org/10.1038/s41420-022-00893-x)

There are two NEW features in this workflow:

- it downloads and generates the reference of interest through the use of Cell Ranger.
(You can modify the reference of interest in the config_new.yaml file see point 3)

- it runs with a singularity container.
(For users that have this possibility on the cluster)

It is meant to be run on a PBS cluster but can be also run locally by omitting the cluster.yaml file and the cluster command.

**Usage:**

1. First [install](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) Snakemake as enviroment of conda and activate it. 
(Be sure to have downloaded or created a docker file with Cell Ranger and all its dependencies insisde, there are many repositories in which you can download docker i.e [here](https://hub.docker.com/).)
```
conda activate snakemake
```

 
2. Create the sample.json file with the [makeJsonSamples.py](https://github.com/raveancic/scRNAaltas_TNBC_mm/blob/master/cl_crt_FASTQ2countmat/makeJsonSamples.py) script. (The .json file are the config files that Snakemake use for parameters in commands.)
```
python makeJsonSamples.py -d [Directory in which FATSQ are stored] -o [prefix of name .json file]
```

3. *(optional)* If you need to modify some parameters for the cluster submission (i.e: mail, RAM, CPU) you can modify the [CreateClusterJsonv2.py](https://github.com/raveancic/scRNAaltas_TNBC_mm/blob/master/cl_crt_FASTQ2countmat/CreateClusterJsonv2.py) file with a text editor and then run it.
(Otherwise you can directly modify the cluster.json file).
```
python CreateClusterJson.py
```

3. Modify the [config_new.yaml](https://github.com/raveancic/scRNAaltas_TNBC_mm/blob/master/cl_crt_FASTQ2countmat/config_new.yaml) with your favorite text editor, here you can tune up all the parameters of interest to run all the commands (rules) that are in in the Snakemake file [GenerateCountv3.smk](https://github.com/raveancic/scRNAaltas_TNBC_mm/blob/master/cl_crt_FASTQ2countmat/GenerateCountv3.smk). It is here in which you can change the FASTA and GTF files according to your experiment (in mine there is the *Mus musculus* ref)

4. Finally you can launch the pipeline with the launchPBS_GenCount.sh. If some options are useless just delete them from the file. Documentation for PBS command can be found [here](https://www.altair.com/pdfs/pbsworks/PBSUserGuide19.2.3.pdf).


This pipeline has been made taking inspiration from the one of @crazyhottommy that can be found [here](https://github.com/crazyhottommy/pyflow-cellranger) which in turn got some hints in [here](https://github.com/maxplanck-ie/10X_snakepipe/blob/master/Snakefile) in order to cope funciontalities of Snakemake and Cell Ranger.

Understanding the behaviour of Snakemake can be found in [here](https://vincebuffalo.com/blog/2020/03/04/understanding-snakemake.html) and the tutorials [here](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html).  
