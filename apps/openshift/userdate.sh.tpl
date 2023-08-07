#!/bin/sh -e

logfile="/var/log/openshift_install.log"

int_dir() {
    echo "Step1: start int_dir" >> $logfile
    
    whoami >> $logfile 2>&1
    pwd >> $logfile 2>&1
    yum install -y expect >> $logfile 2>&1
    mkdir -pv /opt/openshift/pem/ >> $logfile 2>&1
    mkdir -pv /opt/openshift/installation/ >> $logfile 2>&1
    mkdir -pv /opt/openshift/credrequests/ >> $logfile 2>&1
    mkdir -pv /opt/openshift/ccoctl_output/ >> $logfile 2>&1
}
int_alicloud_cred() {
    echo "Step2: start int_alicloud_cred" >> $logfile

    mkdir ~/.alibabacloud/
    echo "[default]" >> ~/.alibabacloud/credentials
    echo "enable = true" >> ~/.alibabacloud/credentials
    echo "type = access_key" >> ~/.alibabacloud/credentials
    echo -e "access_key_id = ${ak}" >> ~/.alibabacloud/credentials
    echo -e "access_key_secret = ${sk}" >> ~/.alibabacloud/credentials
}
config_cco() {
    echo "Step3: start config_cco" >> $logfile

    wget -P /tmp https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-install-linux.tar.gz >> $logfile 2>&1
    wget -P /tmp https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz >> $logfile 2>&1
    tar -zxvf /tmp/openshift-install-linux.tar.gz -C /tmp >> $logfile 2>&1
    tar -zxvf /tmp/openshift-client-linux.tar.gz -C /tmp >> $logfile 2>&1
    cp /tmp/oc /tmp/kubectl /tmp/openshift-install /usr/bin/ >> $logfile 2>&1
    cat > ~/.pull-secret<<EOF
${pull_secret}
EOF
}
config_ccoctl() {
    echo "Step4: start config_ccoctl" >> $logfile

    RELEASE_IMAGE=$(openshift-install version | awk '/release image/ {print $3}')
    CCO_IMAGE=$(oc adm release info --image-for='cloud-credential-operator' $RELEASE_IMAGE) >> $logfile 2>&1
    oc image extract $CCO_IMAGE --file="/usr/bin/ccoctl" -a ~/.pull-secret >> $logfile 2>&1
    chmod 775 ccoctl && mv ccoctl /usr/bin/
    ccoctl --help
}
generate_ssh_pem() {
    echo "Step5: start generate_ssh_pem" >> $logfile

    ssh-keygen -t rsa -N '' -f /opt/openshift/pem/openshift-cluster.pem
    cp /opt/openshift/pem/* ~/.ssh/
}
generate_installation_conf() {
    echo "Step6: start generate_installation_conf" >> $logfile

    pem_pub=$(cat /root/.ssh/openshift-cluster.pem.pub)
    cat > /opt/openshift/installation/install-config.yaml<<EOF
additionalTrustBundlePolicy: Proxyonly
apiVersion: v1
baseDomain: ${base_domain}
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 3
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
metadata:
  creationTimestamp: null
  name: test
networking:
  clusterNetwork:
  - cidr: ${openshift_cluster_network}
    hostPrefix: 23
  machineNetwork:
  - cidr: ${openshift_machine_network}
  networkType: OVNKubernetes
  serviceNetwork:
  - ${openshift_service_etwork}
platform:
  ${cloudname}:
    region: ${region}
publish: External
pullSecret: '${pull_secret}'
sshKey: |
  ssh-rsa $pem_pub
EOF
    cp  /opt/openshift/installation/install-config.yaml /opt/openshift/installation/install-config.yaml.bak
}
generate_manifests() {
  echo "Step7: start generate_manifests" >> $logfile

  cat > /tmp/install.sh<<EOF
#!/bin/sh -e
sudo -u root /usr/bin/openshift-install create manifests --dir /opt/openshift/installation >> $logfile 2>&1
EOF
  sh /tmp/install.sh
}
get_tool_list() {
  echo "Step8: start get_tool_list" >> $logfile

  RELEASE_IMAGE=$(openshift-install version | awk '/release image/ {print $3}')
  oc adm release extract \
    --credentials-requests \
    --cloud=${cloudname} \
    --to=/opt/openshift/credrequests $RELEASE_IMAGE >> $logfile 2>&1
}
get_ccoctl_output() {
  echo "Step9: start get_ccoctl_output" >> $logfile

  sudo -u root ccoctl ${cloudname} create-ram-users \
    --name openshift-${openshift_cluster_name} \
    --region=${region} \
    --credentials-requests-dir=/opt/openshift/credrequests \
    --output-dir=/opt/openshift/ccoctl_output  >> $logfile 2>&1
  cp /opt/openshift/ccoctl_output/manifests/*credentials.yaml /opt/openshift/installation/manifests/ >> $logfile 2>&1
}
deploy_openshift() {
  echo "Step10: start deploy_openshift" >> $logfile

  sudo -u root /usr/bin/openshift-install create cluster --dir /opt/openshift/installation --log-level=debug >> $logfile 2>&1
}



int_dir
int_alicloud_cred
config_cco
config_ccoctl
generate_ssh_pem
generate_installation_conf
generate_manifests
get_tool_list
get_ccoctl_output
deploy_openshift