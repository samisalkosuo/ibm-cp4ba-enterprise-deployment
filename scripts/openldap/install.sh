#!/bin/bash

# Based on https://github.com/osixia/docker-openldap & https://github.com/jp-gouin/helm-openldap

echo
echo ">>>>Source variables"
. ../variables.sh

echo
echo ">>>>Source functions"
. ../functions.sh

echo
echo ">>>>$(print_timestamp) >>>>$(print_timestamp) OpenLDAP + phpLDAPadmin install started"

echo
echo ">>>>Init env"
. ../init.sh

echo
echo ">>>>$(print_timestamp) Create Project"
oc new-project openldap

echo
echo ">>>>$(print_timestamp) Add anyuid SCC to default SA"
oc adm policy add-scc-to-user anyuid system:serviceaccount:openldap:default

echo
echo ">>>>$(print_timestamp) Add helmchart"
helm repo add helm-openldap https://jp-gouin.github.io/helm-openldap/
helm repo update

echo
echo ">>>>$(print_timestamp) Update OpenLDAP helm values"
yq w -i values.yaml persistence.storageClass "${STORAGE_CLASS_NAME}"
sed -i "s|{{BASE64_UNIVERSAL_PASSWORD}}|$(echo -n ${UNIVERSAL_PASSWORD} | base64)|g" values.yaml
sed -i "s|{{UNIVERSAL_PASSWORD}}|${ESCAPED_UNIVERSAL_PASSWORD}|g" values.yaml

echo
echo ">>>>$(print_timestamp) Install helm release"
# Custom chema LDIF based on https://stackoverflow.com/questions/45511696/creating-a-new-objectclass-and-attribute-in-openldap
helm install openldap helm-openldap/openldap-stack-ha --values values.yaml --version 2.1.5

echo
echo ">>>>$(print_timestamp) Create phpLDAPadmin Route"
oc create route edge openldap-phpldapadmin --hostname=phpldapadmin.${OCP_APPS_ENDPOINT} \
--service=openldap-phpldapadmin --insecure-policy=Redirect --cert=../global-ca/wildcard.crt \
--key=../global-ca/wildcard.key --ca-cert=../global-ca/global-ca.crt

echo
echo ">>>>$(print_timestamp) Wait for phpLDAPadmin Deployment to be Available"
wait_for_k8s_resource_condition deployment/openldap-phpldapadmin Available

echo
echo ">>>>$(print_timestamp) Wait for OpenLDAP Ready state"
wait_for_k8s_resource_condition pod/openldap-openldap-stack-ha-0 Ready

echo
echo ">>>>$(print_timestamp) OpenLDAP + phpLDAPadmin install completed"