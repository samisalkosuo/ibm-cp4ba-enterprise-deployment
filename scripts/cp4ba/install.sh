#!/bin/bash

# Based on https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=kubernetes-installing-enterprise-deployments

echo
echo ">>>>Source variables"
. ../variables.sh

echo
echo ">>>>Source functions"
. ../functions.sh

echo
echo ">>>>$(print_timestamp) CP4BA install started"

echo
echo ">>>>Init env"
. ../init.sh

echo
echo ">>>>$(print_timestamp) Repository"
./repository.sh
exit_test $? "CP4BA Repository Failed"

echo
echo ">>>>$(print_timestamp) DBs"
./dbs.sh
exit_test $? "CP4BA DBs Failed"

echo
echo ">>>>$(print_timestamp) Predeploy"
./predeploy.sh
exit_test $? "CP4BA Predeploy Failed"

echo
echo ">>>>$(print_timestamp) Deploy"
./deploy.sh
exit_test $? "CP4BA Deploy Failed"

echo
echo ">>>>$(print_timestamp) Postdeploy"
./postdeploy.sh
exit_test $? "CP4BA Postdeploy Failed"

echo
echo ">>>>$(print_timestamp) CP4BA install completed"