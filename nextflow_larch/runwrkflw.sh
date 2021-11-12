#!/bin/bash
#
#SBATCH -o run%J.out
#SBATCH -e run%J.err
#SBATCH --job-name=run_wrkflw
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
##SBATCH --mem-per-cpu=40000
#SBATCH --partition=htc
####SBATCH --gres=gpu:2

module load singularity
module load nextflow

nextflow run xas_main.nf -profile slurm_singularity
