
## 1. Prerequisites 
1. `gcloud` should be installed.
1. This stack requires one GCP project


## 2. Bootstrap 
1. `git clone git@github.com:jhuntoo/product-list.git && cd product-list`
1. `export GCP_PROJECT=<your GCP project>`
1.  `export STACK_PREFIX="candidate-jlee"` or set as desired 
1.  `export BUCKET_PREFIX="${GCP_PROJECT}-${STACK_PREFIX}"` or set as desired 
1. `make boostrap`


## 3. Provision cluster, Build app & Deploy 
1. `make deploy`

## 4. Test autoscaling
1. Generate artificial load (the script uses [vegeta](https://github.com/tsenart/vegeta))
    ```
    export LOADBALANCER_IP=<get terraform output value from the previous command>
    make perform-load 
    ```
1. Observe replicas being created, connect to the cluster and watch 
    ```bash
    gcloud container clusters get-credentials ${STACK_PREFIX}-cluster --region europe-west1 --project ${GCP_PROJECT}
    watch kubectl get pods -n product-list
    ```

## 5. Cleanup
This will teardowm the terraform managed resources, and remove most of the boostrapped automation as well
*Warning*: this remove the IAM policy bindings from the `<project id>@cloudbuild.gserviceaccount.com` Service Account. The roles are `roles/editor`, `roles/iam.securityAdmin` and `roles/container.admin`. It's possible that these policy bindings may have already existed before running this project, so if that's the case and you want to keep them, comment out the relevant bits in (cleanup.sh)[./scripts/cleanup.sh] 

```
make cleanup
```