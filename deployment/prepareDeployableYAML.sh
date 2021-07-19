#!/bin/bash

TEMPLATES_FOLDER=./templates
DEST_FOLDER=./deployables
TEMPLATES="ca-bundle.yaml crd.yaml deployment.yaml mutatingwebhook.yaml service.yaml"

# Defaults

DEFAULT_SIDECAR_INJECTION_IMAGE="cyberark/sidecar-injector:latest"
DEFAULT_AUTHENTICATOR_IMAGE="cyberark/conjur-kubernetes-authenticator:latest"
DEFAULT_SECRETLESS_IMAGE="cyberark/secretless-broker:latest"
DEFAULT_SERVICE_NAME="cyberark-sidecar-injector"

usage(){
cat << EOF
usage: ${0} [OPTIONS]

The following flags are available to configure the deployment. They can only take on non-empty values.

        --namespace                 Name of the OpenShift namespace which will host the injector pod and related objects (Required)

        --sidecar-injector-image    Container image for the Sidecar Injector.
                                    (Optional, default: ${DEFAULT_SIDECAR_INJECTION_IMAGE})
 
        --secretless-image          Container image for the Secretless sidecar.
                                    (Optional, default: ${DEFAULT_SECRETLESS_IMAGE})
 
        --authenticator-image       Container image for the Kubernetes Authenticator sidecar.
                                    (Optional, default: ${DEFAULT_AUTHENTICATOR_IMAGE})
             
        --service-name              Name of the OpenShift service to be created
                                    (Optional, default: ${DEFAULT_SERVICE_NAME})
EOF
}


sidecarInjectorImage=${DEFAULT_SIDECAR_INJECTION_IMAGE}
authenticatorImage=${DEFAULT_AUTHENTICATOR_IMAGE}
secretlessImage=${DEFAULT_SECRETLESS_IMAGE}

namespace=""
serviceName=${DEFAULT_SERVICE_NAME}

while [[ $# -gt 0 ]]; do
    case ${1} in
        --sidecar-injector-image)
            sidecarInjectorImage="${2}"
            shift
            ;;
        --secretless-image)
            secretlessImage="${2}"
            shift
            ;;
        --authenticator-image)
            authenticatorImage="${2}"
            shift
            ;;
        --namespace)
            namespace="${2}"
            shift
            ;;
        --service-name)
            serviceName="${2}"
            shift
            ;;
        *)
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ -z "${namespace}" ]] ; then
    echo "namespace field is mandatory!"
    usage
    exit 2
fi

## need to export them in order to use with envsubst
export sidecarInjectorImage
export authenticatorImage
export secretlessImage
export namespace
export serviceName

if [[ -d ${DEST_FOLDER} ]] ; then
    echo "WARN ${DEST_FOLDER} already exists! the files will be overridden!"
else
    mkdir ${DEST_FOLDER}
fi

for template in ${TEMPLATES} ; do
    cat ${TEMPLATES_FOLDER}/${template} | envsubst > ${DEST_FOLDER}/${template}
done

