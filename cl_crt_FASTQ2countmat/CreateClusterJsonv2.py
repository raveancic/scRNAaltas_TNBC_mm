
import json
import os
import argparse

data={}

data["__default__"] = {}
data["dwn_ref"]= {}
data["gzip_ref"] = {}
data["cr_filter_ref"] = {}
data["cr_create_index"] = {}
data["cr_count"] = {}

data["__default__"] = {
    'mail': 'alessandro.raveane@ieo.it',
    'ncpus': 1,
    'mem': 8,
    'stdout': 'sbatch_log/{rule}.out',
    'stderr': 'sbatch_log/{rule}.err',
    'project_name': 'atlas_mm10'
    }

data["cr_create_index"] ={
    'ncpus':12
}

data["cr_count"] = {
    'name': '{rule}_{wildcards.sample}',
    'ncpus': 12,
    'mem': 64,
    'stdout': 'sbatch_log/{rule}_{wildcards.sample}.out',
    'stderr': 'sbatch_log/{rule}_{wildcards.sample}.err'

}


with open('cluster.json', 'w') as outfile:
    json.dump(data, outfile)
