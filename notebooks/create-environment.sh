#!/usr/bin/env bash
BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
conda create --yes --name notebooks --file notebooks/conda-requirements.txt
source activate notebooks
pip install -r notebooks/requirements.txt
$BIN_DIR/download-nltk.py
source deactivate
