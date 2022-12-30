                        #########################################
                        ###                                   ###
                        ###       Replication Parameters      ###
                        ###                                   ###
                        #########################################

###############################
###                         ###
###         Common          ###
###                         ###
###############################

export USE_HOST_ALIAS="no";                                          # If "yes", use *_HOST_ALIAS instead of *_HOST_URL, *_HOST_USR & *_HOST_KEY
export ALLOW_SUDO_ASKPASS_CREATION="yes";                            # If "yes", a temporary SUDO_ASKPASS environment variable will be created in '/dev/shm'
                                                                     #        which avoids typing passwords every time


###############################
###                         ###
###          Master         ### 
###                         ###
###############################

export MASTER_HOST_URL="loso.erpnext.host";                           # Domain name of host
export MASTER_HOST_USR="admin";                                       # ERPNext user name
export MASTER_HOST_PWD="password#1";                                  # ERPNext user password
export MASTER_HOST_SSH_PORT="22";                                     # SSH port
export MASTER_HOST_KEY="admin_loso_erpnext_host";                     # ERPNext user SSH key registered in authorized_keys of user 'MASTER_HOST_USR'
export MASTER_HOST_ALIAS="lenh";                                      # SSH host alias name
export MASTER_BENCH_HOME=/home/${MASTER_HOST_USR};                    # Directory where the Frappe Bench is installed
export MASTER_BENCH_NAME=frappe-bench-LENH;                           # The name given to the Frappe Bench directory
export MASTER_BENCH_PATH=${MASTER_BENCH_HOME}/${MASTER_BENCH_NAME};   # Full path to Bench directory



###############################
###                         ###
###         Slave           ###
###                         ###
###############################

export SLAVE_HOST_URL="stg.erpnext.host";                             # Domain name of host
export SLAVE_HOST_USR="adm";                                          # ERPNext user name
export SLAVE_HOST_PWD="password#2";                                   # ERPNext user password
export SLAVE_HOST_SSH_PORT="22";                                      # SSH port
export SLAVE_HOST_KEY="adm_stg_erpnext_host";                         # ERPNext user SSH key registered in authorized_keys of user 'SLAVE_HOST_USR'
export SLAVE_HOST_ALIAS="serpht";                                     # SSH host alias name
export SLAVE_BENCH_HOME=/home/${SLAVE_HOST_USR};                      # Directory where the Frappe Bench is installed
export SLAVE_BENCH_NAME=frappe-bench-SERPHT;                          # The name given to the Frappe Bench directory
export SLAVE_BENCH_PATH=${SLAVE_BENCH_HOME}/${SLAVE_BENCH_NAME};      # Full path to Bench directory

export SLAVE_DB_ROOT_PWD="password#3";                                # Root password for MariaDb of slave         
export SLAVE_DB_PWD="password#4";                                     # Replicator slave password         

export RESTORE_SITE_CONFIG="yes";
export KEEP_SITE_PASSWORD="yes";


###############################
###                         ###
###       For Testing       ###
###                         ###
###############################

# export DRY_RUN_ONLY="yes";                 not yet implemented        # If "yes", run checks but make no permanent changes 
export TEST_CONNECTIVITY="yes"                                        # If "yes", the ability to log on and execute a command will be tested for each host.
export REPEAT_SLAVE_WITHOUT_MASTER="no";                              # If "yes", skips uploads to slave and all calls to and downloads from master
export UPLOAD_MASTER_BACKUP="yes";                                    # If "yes", upload master files to slave (ignored if REPEAT_SLAVE_WITHOUT_MASTER="no")



# Reset Master

declare SLAVE_IP=$(dig ${SLAVE_HOST_URL} A +short);
declare SLAVE_USR=${SLAVE_HOST_URL//./_};

echo -e "

sudo -A cp ${HOME}/${MASTER_BENCH_NAME}/BaRe/misc/50-server.cnf /etc/mysql/mariadb.conf.d;

sudo -A systemctl restart mariadb;

mysql mysql;

# CREATE USER '${SLAVE_USR}'@'${SLAVE_IP}' IDENTIFIED BY '${SLAVE_DB_PWD}';
# GRANT REPLICATION SLAVE ON *.* TO '${SLAVE_USR}'@'${SLAVE_IP}';

SELECT Host, User, Repl_slave_priv, Delete_priv FROM user;
SELECT Host, Db, User FROM db;

DROP USER ${SLAVE_USR};
FLUSH PRIVILEGES;
SHOW MASTER STATUS;
";

# Reset Slave

echo -e "

sudo -A cp ${HOME}/${SLAVE_BENCH_NAME}/BaRe/misc/50-server.cnf /etc/mysql/mariadb.conf.d;

sudo -A systemctl restart mariadb;

mysql mysql;

FLUSH PRIVILEGES;

RESET MASTER;

STOP SLAVE;

SHOW SLAVE STATUS;
";



