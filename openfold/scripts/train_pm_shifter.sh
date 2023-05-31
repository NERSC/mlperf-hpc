#!/bin/bash
#SBATCH -J mlperf-openfold-ref
#SBATCH -A m4291
#SBATCH -q regular
#SBATCH -C gpu&hbm80g
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-node=4
#SBATCH --cpus-per-task=32
#SBATCH --image=sfarrell/openfold-ref:23.02
#SBATCH --module=gpu,nccl-2.15

# Vars with defaults
NEXP="${NEXP:-1}"
export LOGDIR="${LOGDIR:-${SCRATCH}/openfold-ref/results/${SLURM_JOB_ID}}"
export DATA_DIR="${DATA_DIR:-/pscratch/sd/s/sfarrell/openfold-ref/data/pdb_data}"
export CHECKPOINT_PATH="${CHECKPOINT_PATH:-/global/cfs/cdirs/m4291/gsharing/openfold/mlperf_hpc_openfold_resumable_checkpoint_v1.pt}"

# Other settings
export MASTER_ADDR=$(hostname)
export FI_MR_CACHE_MONITOR=userfaultfd

# Extra command line args
args=$@

# Setup directories
mkdir -p "${LOGDIR}"

# Run experiments
for iexp in $(seq 1 "${NEXP}"); do

    echo "Beginning trial ${iexp} of ${NEXP}"

    # Run experiment
    #export SEED=${_seed_override:-$RANDOM}
    srun -u --mpi=pmi2 shifter \
        bash scripts/run_training.sh --distributed ${args}

done
