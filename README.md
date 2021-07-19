# CyberArk Sidecar Injector

This project is an OpenShift flavoured installation for the **CyberArk Sidecar Injector** project on [github](https://github.com/cyberark/sidecar-injector)

For reference on how to properly configure the injection can be found at [sidecar-injector - Using the Sidecar Injector](https://github.com/cyberark/sidecar-injector#using-the-sidecar-injector)

the main difference between this setup and the one provided in CyberArk repository is that instead of invoking Kubernetes APIs for generating the certificates: OpenShift injection feature will be used (in order to avoid further maintenance)


### Installing the Sidecar Injector (Manually)

#### Create a dedicated Namespace

Create a project `injectors`, where you will deploy the CyberArk Sidecar Injector
Webhook components.

1. Create project

    ~~~bash
    ~$ oc new-project injectors
    ~~~

#### Create the deployable files from the templates

2. Run the `prepareDeployableYAML.sh` script

    ~~~bash
    ~$ prepareDeployableYAML.sh --namespace injectors
    ~~~

the command takes the following parameters:

| Parameter   | Description | Default Value | Required |
| ----------- | ----------- | ----------- | ----------- |
| --namespace      | Name of the OpenShift namespace which will host the injector pod and related objects  |    | Yes    |
| --sidecar-injector-image   | Container image for the Sidecar Injector.        | cyberark/sidecar-injector:latest   | No |
| --secretless-image | Container image for the Secretless sidecar. | cyberark/secretless-broker:latest   | No   | 
| --authenticator-image  | Container image for the Kubernetes Authenticator sidecar. | cyberark/conjur-kubernetes-authenticator:latest   | No    |
| --service-name | Name of the OpenShift service to be created | cyberark-sidecar-injector   | No   |


3. Deploy resources

    ~~~bash
    ca-bundle.yaml
    ~$ oc apply -f deployables/deployment.yaml -n injectors
    ~$ oc apply -f deployables/service.yaml -n injectors
    ~$ oc apply -f deployables/mutatingwebhook.yaml -n injectors
    ~$ oc apply -f deployables/crd.yaml -n injectors
    ~$ oc apply -f deployables/service.yaml -n injectors
    ~~~

#### Verify Sidecar Injector Installation

1. The sidecar injector webhook should be running

    ~~~bash
    ~$ oc get pods -n injectors 

    NAME                                                  READY     STATUS    RESTARTS   AGE
    cyberark-sidecar-injector-bbb689d69-882dd   1/1       Running   0          5m
    ~~~
