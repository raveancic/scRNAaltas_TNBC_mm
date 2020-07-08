# scRNA count matrix generator with Cell Ranger
### (a Snakemake pipeline)


This pipeline allows to generate the count matrix (and the .bam files) from FASTQ files of scRNA generated with 10xgenomics.

There are two NEW features in this workflow:

- it downloads and generates the reference of interest through the use of Cell Ranger.
(You can modify the reference of interest in the config_new.yaml file see point 3)

- it runs with a singularity container.
(For user that have this possibility on the cluster)

It is meant to be run on a PBS cluster but can be also run locally by omitting the cluster.yaml file and the cluster command.

**Usage:**

1. First [install](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) Snakemake as enviroment of conda and activate it. Parallely download and/or create a docker file with Cell Ranger and all its dependencies insisde, there are many repositories in which you can download docker as [here](https://hub.docker.com/).
```
conda activate snakemake
```
2. Create the sample.json file with the makeJson.py script. The .json file are the config files that Snakemake use for parameters in commands.

```
python makeJson.py -d [Directory in which FATSQ are stored] -o [prefix of name .json file]
```

3. *(optional)* If you need to modify some parameters for the cluster submission (i.e: mail, RAM, CPU) you have to modify the CreateClusterJson.py file with a text editor and then run it with, it will produce the cluster.json file. Otherwise you can directly modify the cluster.json file.

```
python CreateClusterJson.py
```

3. By opening with your favorite text editor the file config_new.yaml you can tune up all the parameters of interest to run all the commands that are in in the Snakemake file GenerateCountv2.smk. Be careful on the FASTA and GTF filles, if you are using *Homo Sapiens* you need to update them.

4. Finally you can launch the pipeline with the launchPBS_GenCount.sh. In here there are different options that can be found useless for many of you.


This pipeline has been made taking inspiration from the one of @crazyhottommy that can be found [here](https://github.com/crazyhottommy/pyflow-cellranger) which in turn got some hints in [here](https://github.com/maxplanck-ie/10X_snakepipe/blob/master/Snakefile) in order to cope funciontalities of Snakemake and Cell Ranger.

Understanding the behaviour of Snakemake can be found in [here](https://vincebuffalo.com/blog/2020/03/04/understanding-snakemake.html) and the tutorials [here](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html).  
