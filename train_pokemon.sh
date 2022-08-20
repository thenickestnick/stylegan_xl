#!/usr/bin/env bash
mkdir ./data

dataset_archive_path=./data/few-shot-image-datasets.zip
if test -f "$dataset_archive_path"; then
    echo "Dataset archive exists at $dataset_archive_path, not downloading."
else
    echo "Downloading $dataset_archive_path"
    wget https://aimote-datasets.s3.us-west-1.amazonaws.com/few-shot-image-datasets.zip -P ./data
    unzip -q $dataset_archive_path -d ./data
fi

image_dir_path=./data/few-shot-images/pokemon
processed_archive_path=./data/processed/pokemon256.zip

if test -f "processed_archive_path"; then
    echo "Processed dataset already found at $processed_archive_path, skipping processing."
else
    echo "Processing dataset into archive $processed_archive_path"
    python dataset_tool.py \
    --source=$image_dir_path \
    --dest=$processed_archive_path \
    --resolution=256x256 \
    --transform=center-crop
fi

python train.py \
--data=$image_dir_path \
--outdir=$processed_archive_path \
--cfg=stylegan3-t \
--gpus=1 \
--batch=8 \
--mirror=True \
--snap=10 \
--batch-gpu=8 \
--kimg=10000 \
--syn_layers=10
