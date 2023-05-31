#!/bin/bash

# Forward additional command line arguments
OTHER_ARGS=$@

# Distributed settings from SLURM
export RANK=$SLURM_PROCID
export LOCAL_RANK=$SLURM_LOCALID
export GROUP_RANK=$SLURM_NODEID
export WORLD_SIZE=$SLURM_NTASKS
export LOCAL_WORLD_SIZE=$SLURM_NTASKS_PER_NODE
export MASTER_PORT=29500

set -eux

# Make output directory if necessary
mkdir -p ${LOGDIR}

python train.py \
    --training_dirpath ${LOGDIR} \
    --pdb_mmcif_chains_filepath ${DATA_DIR}/pdb_mmcif/processed/chains.csv \
    --pdb_mmcif_dicts_dirpath ${DATA_DIR}/pdb_mmcif/processed/dicts \
    --pdb_obsolete_filepath ${DATA_DIR}/pdb_mmcif/processed/obsolete.dat \
    --pdb_alignments_dirpath ${DATA_DIR}/open_protein_set/processed/pdb_alignments \
    --initialize_parameters_from ${CHECKPOINT_PATH} \
    --seed ${SEED:-1234567890} \
    --num_train_iters ${NUM_TRAIN_ITERS:-2000} \
    --val_every_iters 40 \
    --local_batch_size 1 \
    --init_lr 1e-3 \
    --final_lr 5e-5 \
    --warmup_lr_length 0 \
    --init_lr_length 2000 \
    --num_train_dataloader_workers 14 \
    --num_val_dataloader_workers 2 \
    --distributed \
    ${OTHER_ARGS}
