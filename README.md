
## Prerequisites 
1. `gcloud` should be installed.
1. This stack requires one GCP project


## Bootstrap 
1. `git clone git@github.com:jhuntoo/product-list.git && cd product-list`
1. `export GCP_PROJECT=<your GCP project>`
1.  `export BUCKET_PREFIX="${GCP_PROJECT}-candidate-jonathon-lee"` or set as desired 
1. `make boostrap`


## Build & Deploy 
1. `make deploy`