#!/bin/sh -eux
# appdynamics gcp gke monitoring lab cloud-init script to initialize gcp compute engine instance.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] gcp user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
gcp_gce_hostname="${gcp_gce_hostname:-terraform-user}"
gcp_gce_domain="${gcp_gce_domain:-localdomain}"
use_gcp_gce_num_suffix="${use_gcp_gce_num_suffix:-true}"

# configure public keys for specified user. --------------------------------------------------------
user_home=$(eval echo "~${user_name}")
user_authorized_keys_file="${user_home}/.ssh/authorized_keys"
user_key_name="Channel-CNAO-Workshop"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkVnb7a69d+MSRG08WdqfvWXEpnT544XzohdZ0sIs5fRLU+pAh48F+BieIqxvCUKIUDXQFP04iQmoo5MKiLH42YVfDmsoidLDejiDS0O5KTn8DS6jA2akeT19xpYweKmRcw4kz+DeBe9dmYmggGQYZx48bSwBrwHcjvJciYTbLyBxmTx/kUIfn4Ub81cfoKq/m5qh/LnyZsXo+ZWj6kGDWsqSpX3I0jysaEsvQDRoRUUe0gSPIe7Y3IfTLsCj0PxzFMDqASeHMMGGoBzMhdWXexiDCUIcToGRKTC6FVfDEZs1kTYKJe7hp0CJtZHMdM7yAhb1JSAURT6ZcOwopxIH7 Channel-CNAO-Workshop"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# define gcp gke monitoring lab user variables. ----------------------------------------------------
# retrieve the name attribute from the gce vm instance metadata.
gcp_gce_instance_name=$(curl --silent -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name")

# if num suffix is present, retrieve the value.
if [ "$use_gcp_gce_num_suffix" == "true" ]; then
  gcp_gce_instance_count=$(echo ${gcp_gce_instance_name} | awk -F "-" '{print $2}')
else
  gcp_gce_instance_count=""
fi

# if date is present, split the instance name into separate hostname and date variables.
if [ $(echo "$gcp_gce_instance_name" | grep '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$') ]; then
  gcp_gce_hostname="${gcp_gce_instance_name:0:-11}"
  gcp_gce_instance_date="${gcp_gce_instance_name: -10}"
else
  gcp_gce_hostname="${gcp_gce_instance_name}"
  gcp_gce_instance_date=""
fi

# set the gke cluster name.
if [ ! -z "$gcp_gce_instance_date" ]; then
  gcp_gke_cluster_name="gke-${gcp_gce_instance_count}-cluster-${gcp_gce_instance_date}"
else
  gcp_gke_cluster_name="gke-${gcp_gce_instance_count}-cluster"
fi

# retrieve the gke cluster zone (location).
gcp_gke_cluster_zone=$(gcloud container clusters list --filter="name:${gcp_gke_cluster_name}" --format="value(location)")

# use the stream editor to substitute new values into the user bash config. ------------------------
bashrc_config_file="${user_home}/.bashrc"
cp -p ${bashrc_config_file} ${bashrc_config_file}.orig

# define stream editor search strings.
bashrc_search="# define prompt code and colors."

# define stream editor gcp gke monitoring lab config substitution strings.
lab_config_line_01="# define gcp gke monitoring lab environment variables."
lab_config_line_02="gcp_gke_cluster_name=${gcp_gke_cluster_name}"
lab_config_line_03="export gcp_gke_cluster_name"
lab_config_line_04="gcp_gke_cluster_zone=${gcp_gke_cluster_zone}"
lab_config_line_05="export gcp_gke_cluster_zone"
lab_config_line_06="#appd_controller_host=apm"
lab_config_line_07="#export appd_controller_host"
lab_config_line_08="appd_install_kubernetes_metrics_server=false"
lab_config_line_09="export appd_install_kubernetes_metrics_server"
lab_config_line_10="appd_cluster_agent_auto_instrumentation=false"
lab_config_line_11="export appd_cluster_agent_auto_instrumentation"
lab_config_line_12="#appd_cluster_agent_account_access_key=abcdef01-2345-6789-abcd-ef0123456789"
lab_config_line_13="#export appd_cluster_agent_account_access_key"
lab_config_line_14="appd_cluster_agent_docker_image=edbarberis\/cluster-agent:latest"
lab_config_line_15="export appd_cluster_agent_docker_image"
lab_config_line_16="appd_cluster_agent_application_name=AD-Capital"
lab_config_line_17="export appd_cluster_agent_application_name"
lab_config_line_18=""

# insert lab config lines before this comment: '# define prompt code and colors.'
sed -i -e "s/${bashrc_search}/${lab_config_line_01}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_02}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_03}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_04}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_05}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_06}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_07}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_08}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_09}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_10}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_11}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_12}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_13}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_14}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_15}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_16}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_17}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_18}\n${bashrc_search}/g" ${bashrc_config_file}

# export environment variables.
export gcp_gce_hostname
export gcp_gce_domain

# set the hostname.
./config_gcp_system_hostname.sh
