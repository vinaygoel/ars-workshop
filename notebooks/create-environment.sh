#!/usr/bin/env sh

conda create --yes --name notebooks --file notebooks/conda-requirements.txt
source activate notebooks
pip install -r notebooks/requirements.txt
source deactivate
