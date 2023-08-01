#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Events Service and Controller Platform Services by AppDynamics.
#
# The Events Service is the on-premises data storage facility for unstructured data generated by
# Application Analytics, Database Visibility, and End User Monitoring deployments. It provides
# high-volume, performance-intensive, and horizontally scalable storage for analytics data.
#
# The Controller sits at the center of an AppDynamics deployment. It's where AppDynamics agents
# send data on the activity in the monitored environment. It's also where users go
# to view, understand, and analyze that data.
#
# For more details, please visit:
#   https://docs.appdynamics.com/latest/en/application-performance-monitoring-platform/events-service-deployment
#   https://docs.appdynamics.com/latest/en/appdynamics-essentials/getting-started
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics platform install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
appd_platform_user_name="${appd_platform_user_name:-centos}"
appd_platform_user_group="${appd_platform_user_group:-centos}"
set +x  # temporarily turn command display OFF.
appd_platform_admin_username="${appd_platform_admin_username:-admin}"
appd_platform_admin_password="${appd_platform_admin_password:-welcome1}"
set -x  # turn command display back ON.
appd_platform_home="${appd_platform_home:-platform}"
appd_platform_name="${appd_platform_name:-My Platform}"
appd_platform_description="${appd_platform_description:-My platform config.}"
appd_platform_product_home="${appd_platform_product_home:-product}"
appd_platform_hosts="${appd_platform_hosts:-platformadmin}"

# [OPTIONAL] appdynamics events service install parameters [w/ defaults].
appd_events_service_hosts="${appd_events_service_hosts:-platformadmin}"
appd_events_service_profile="${appd_events_service_profile:-DEV}"

# [OPTIONAL] appdynamics controller install parameters [w/ defaults].
appd_controller_primary_host="${appd_controller_primary_host:-platformadmin}"
set +x  # temporarily turn command display OFF.
appd_controller_admin_username="${appd_controller_admin_username:-admin}"
appd_controller_admin_password="${appd_controller_admin_password:-welcome1}"
appd_controller_root_password="${appd_controller_root_password:-welcome1}"
appd_controller_mysql_password="${appd_controller_mysql_password:-welcome1}"
set -x  # turn command display back ON.

# [OPTIONAL] cnao lab devops home folder [w/ default].
devops_home="${devops_home:-/opt/cnao-lab-devops}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Events Service and Controller Platform Services by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_platform_user_name="centos"                     # [optional] platform user name (defaults to 'centos').
    [root]# export appd_platform_user_group="centos"                    # [optional] platform group (defaults to 'centos').
    [root]# export appd_platform_admin_username="admin"                 # [optional] platform admin user name (defaults to user 'admin').
    [root]# export appd_platform_admin_password="welcome1"              # [optional] platform admin password (defaults to 'welcome1').
    [root]# export appd_platform_home="platform"                        # [optional] platform home folder (defaults to 'machine-agent').
    [root]# export appd_platform_name="My Platform"                     # [optional] platform name (defaults to 'My Platform').
    [root]# export appd_platform_description="My platform config."      # [optional] platform description (defaults to 'My platform config.').
    [root]# export appd_platform_product_home="product"                 # [optional] platform base installation directory for products
                                                                        #            (defaults to 'product').
    [root]# export appd_platform_hosts="platformadmin"                  # [optional] platform hosts
                                                                        #            (defaults to 'platformadmin' which is the localhost).

  [OPTIONAL] appdynamics events service install parameters [w/ defaults].
    [root]# export appd_events_service_hosts="platformadmin"            # [optional] events service hosts
                                                                        #            (defaults to 'platformadmin' which is the localhost).
    [root]# export appd_events_service_profile="DEV"                    # [optional] appd events service profile (defaults to 'DEV').
                                                                        #            valid profiles are:
                                                                        #              'DEV', 'dev', 'PROD', 'prod'

  [OPTIONAL] appdynamics controller install parameters [w/ defaults].
    [root]# export appd_controller_primary_host="platformadmin"         # [optional] controller primary host
                                                                        #            (defaults to 'platformadmin' which is the localhost).
    [root]# export appd_controller_admin_username="admin"               # [optional] controller admin user name (defaults to 'admin').
    [root]# export appd_controller_admin_password="welcome1"            # [optional] controller admin password (defaults to 'welcome1').
    [root]# export appd_controller_root_password="welcome1"             # [optional] controller root password (defaults to 'welcome1').
    [root]# export appd_controller_mysql_password="welcome1"            # [optional] controller mysql root password (defaults to 'welcome1').

  [OPTIONAL] cnao lab devops home folder [w/ default].
    [root]# export devops_home="/opt/cnao-lab-devops"                   # [optional] devops home (defaults to '/opt/cnao-lab-devops').

  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -n "$appd_events_service_profile" ]; then
  case $appd_events_service_profile in
      DEV|dev|PROD|prod)
        ;;
      *)
        echo "Error: invalid 'appd_events_service_profile'."
        usage
        exit 1
        ;;
  esac
fi

# set current date for temporary filename. ---------------------------------------------------------
######curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# reduce the default sizing for the appdynamics events service production profile. -----------------
# find events service version path.
######appd_events_service_profile_path="${appd_home}/${appd_platform_home}/platform-admin/archives/events-service"
######appd_events_service_version=$(find ${appd_events_service_profile_path} -type d -name '[0-9][0-9]*' -printf '%f')
######appd_events_service_version_path="${appd_events_service_profile_path}/${appd_events_service_version}"

# change to the events service playbooks host requirements folder.
######cd ${appd_events_service_version_path}/playbooks/host_requirements

# save a copy of the current file.
######appd_events_service_dev_file="dev-host-requirements.groovy"
######appd_events_service_prod_file="prod-host-requirements.groovy"

######if [ -f "${appd_events_service_prod_file}.orig" ]; then
######  cp -p ${appd_events_service_prod_file} ${appd_events_service_prod_file}.${curdate}
######else
######  cp -p ${appd_events_service_prod_file} ${appd_events_service_prod_file}.orig
######fi

# use the stream editor to substitute the new values.
######sed -i -e "/^eventsServiceMinRamSizeInMb = 12288/s/^.*$/eventsServiceMinRamSizeInMb = 1024/" ${appd_events_service_prod_file}
######sed -i -e "/^eventsServiceMinCpus = 4/s/^.*$/eventsServiceMinCpus = 1/" ${appd_events_service_prod_file}
######sed -i -e "/^eventsServiceMinDataSpaceInMb = 128000/s/^.*$/eventsServiceMinDataSpaceInMb = 2048/" ${appd_events_service_prod_file}

# set appdynamics platform installation variables. -------------------------------------------------
appd_platform_folder="${appd_home}/${appd_platform_home}"
appd_product_folder="${appd_home}/${appd_platform_home}/${appd_platform_product_home}"

# start the appdynamics enterprise console. --------------------------------------------------------
cd ${appd_platform_folder}/platform-admin/bin
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh start-platform-admin" - ${appd_platform_user_name}

# verify installation.
cd ${appd_platform_folder}/platform-admin/bin
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-platform-admin-version" - ${appd_platform_user_name}

# login to the appdynamics platform. ---------------------------------------------------------------
set +x  # temporarily turn command display OFF.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh login --user-name \"${appd_platform_admin_username}\" --password \"${appd_platform_admin_password}\"" - ${appd_platform_user_name}
set -x  # turn command display back ON.

# create an appdynamics platform. ------------------------------------------------------------------
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh create-platform --name \"${appd_platform_name}\" --description \"${appd_platform_description}\" --installation-dir \"${appd_product_folder}\"" - ${appd_platform_user_name}

# add local host ('platformadmin') to platform. ----------------------------------------------------
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh add-hosts --hosts \"${appd_platform_hosts}\"" - ${appd_platform_user_name}

# validate platform hosts.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh list-hosts" - ${appd_platform_user_name}

# install appdynamics events service. --------------------------------------------------------------
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh install-events-service --platform-name \"${appd_platform_name}\" --profile \"${appd_events_service_profile}\" --hosts \"${appd_events_service_hosts}\"" - ${appd_platform_user_name}

# verify installation.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-events-service-health" - ${appd_platform_user_name}

# configure the appdynamics events service as a service. -------------------------------------------
systemd_dir="/etc/systemd/system"
appd_events_service_service="appdynamics-events-service.service"
service_filepath="${systemd_dir}/${appd_events_service_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"

  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The AppDynamics Events Service." >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target appdynamics-enterprise-console.service" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "Type=forking" >> "${service_filepath}"
  echo "RemainAfterExit=true" >> "${service_filepath}"
  echo "TimeoutStartSec=300" >> "${service_filepath}"

  if [ "$appd_platform_user_name" != "root" ]; then
    echo "User=${appd_platform_user_name}" >> "${service_filepath}"
    echo "Group=${appd_platform_user_group}" >> "${service_filepath}"
  fi

  set +x  # temporarily turn command display OFF.
  echo "ExecStartPre=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh login --user-name ${appd_platform_admin_username} --password ${appd_platform_admin_password}" >> "${service_filepath}"
  set -x  # turn command display back ON.
  echo "ExecStart=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh start-events-service" >> "${service_filepath}"
  echo "ExecStop=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh stop-events-service" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

# enable the events service service to start at boot time.
systemctl enable "${appd_events_service_service}"
systemctl is-enabled "${appd_events_service_service}"

# check current status.
#systemctl status "${appd_events_service_service}"

# install appdynamics controller. ------------------------------------------------------------------
set +x  # temporarily turn command display OFF.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh submit-job --service controller --job install --args controllerPrimaryHost=\"${appd_controller_primary_host}\" controllerAdminUsername=\"${appd_controller_admin_username}\" controllerAdminPassword=\"${appd_controller_admin_password}\" controllerRootUserPassword=\"${appd_controller_root_password}\" newDatabaseRootPassword=\"${appd_controller_mysql_password}\"" - ${appd_platform_user_name}
set -x  # turn command display back ON.

# install license file.
cp ${devops_home}/provisioners/scripts/centos/tools/appd-controller-license.lic ${appd_platform_folder}/product/controller/license.lic
chown -R ${appd_platform_user_name}:${appd_platform_user_group} ${appd_platform_folder}/product/controller/license.lic

# verify installation.
curl --silent http://localhost:8090/controller/rest/serverstatus

# configure the appdynamics controller as a service. -----------------------------------------------
systemd_dir="/etc/systemd/system"
appd_controller_service="appdynamics-controller.service"
service_filepath="${systemd_dir}/${appd_controller_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"

  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The AppDynamics Controller." >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target appdynamics-enterprise-console.service appdynamics-events-service.service" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "Type=forking" >> "${service_filepath}"
  echo "RemainAfterExit=true" >> "${service_filepath}"
  echo "TimeoutStartSec=600" >> "${service_filepath}"
  echo "TimeoutStopSec=120" >> "${service_filepath}"

  if [ "$appd_platform_user_name" != "root" ]; then
    echo "User=${appd_platform_user_name}" >> "${service_filepath}"
    echo "Group=${appd_platform_user_group}" >> "${service_filepath}"
  fi

  set +x  # temporarily turn command display OFF.
  echo "ExecStartPre=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh login --user-name ${appd_platform_admin_username} --password ${appd_platform_admin_password}" >> "${service_filepath}"
  set -x  # turn command display back ON.
  echo "ExecStart=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh start-controller-appserver" >> "${service_filepath}"
  echo "ExecStop=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh stop-controller-appserver" >> "${service_filepath}"
  echo "ExecStop=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh stop-controller-db" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

# enable the controller service to start at boot time.
systemctl enable "${appd_controller_service}"
systemctl is-enabled "${appd_controller_service}"

# check current status.
#systemctl status "${appd_controller_service}"

# verify overall platform installation. ------------------------------------------------------------
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh list-supported-services" - ${appd_platform_user_name}
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-service-status --service controller" - ${appd_platform_user_name}
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-service-status --service events-service" - ${appd_platform_user_name}

# shutdown the appdynamics platform components. ----------------------------------------------------
# stop the appdynamics controller.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh stop-controller-appserver" - ${appd_platform_user_name}

# stop the appdynamics controller database.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh stop-controller-db" - ${appd_platform_user_name}

# stop the appdynamics events service.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh stop-events-service" - ${appd_platform_user_name}

# stop the appdynamics enterprise console.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh stop-platform-admin" - ${appd_platform_user_name}
