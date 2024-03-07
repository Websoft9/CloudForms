# tf-ali-openshift-cluster

create an openshift cluster to alicloud write by terraform & shell

## Quick Start

First, Update the value of variables in file variables.tf

Retrieve the PULL SECRET content from [REDHAT](https://console.redhat.com/openshift/install/alibaba/installer-provisioned) and paste it into file pull-secret.txt

Then go run terraform, good luck
```sh
terraform plan
terraform apply
```

**All output logs of the deployment process will be recorded in the file /var/log/openshift_install.log on the openshift-launcher server.**