# k8s-able Go local development environment

This is a PoC toy project that I used to simulate the definition of the whole development lifecycle for a Go application that would end up deployed on k8s.

It brings some cool features for the dev[ops]:

* Easy local Kubernetes k3s cluster on top of Docker
* Fast, lively build+reload+bdd-test Go applications inside the container thanks to [Gin]
* Define deploy pipelines using [skaffold]
* Extend your base k8s profiles with [kustomize] (or extend existing charts)
* Seamlessly export your local application to the world using [ngrok]

And some extras ones for [dev]ops:

* Simulate larger k8s deployments using [ansible]-defined "VMs" using cheap [footloose] containers as base
* Deploy on a production [rio]-hosted PaaS on larger k8s deployments in favor of the local k3s

## Tools involved

* Some [gin]: a live reload utility for Go apps
* [docker]
* [k3s]: lightweight k8s distro
* [k3d]: k3s k8s distro on top of docker
* [skaffold]: workflow management tool
* [kustomize]: k8s resource derivation tool
* [rio]: stateless application PaaS for k8s
* [cucumber]/[godog]: bdd tool/go implementation
* [ngrok]+[ngrok-kubernetes]: tunneling service to expose local development environments
* [footloose]: cheap "VMs" as containers
* [baids]: shell functions/aliases manager
* [ansible]: CMS (Config Management System) tool

# Setup local develop enviroment

## Requirements

* git
* curl
* bash/zsh (bash recommended)
* [jq]

## Install snippet

When run from the root of this repository, this copy+paste snippet should cleanly install all the necessary tools for the local environment setup:

```
# Clone this repository (this makes no sense since this is being shipped as a zip :)
# git clone $GIT_REPO_URL ~/Projects/go/hello-go
# install baids
curl -sSL https://raw.githubusercontent.com/rcmorano/baids/master/baids | bash -s install
ln -s ${PWD}/baids ${HOME}/.baids/functions.d/hello-go
baids-reload
local-hello-go-setup
```

## Usage

* Bring the local environment up with this skaffold-powered baid: 
```
local-hello-go-dev
```
* Access traefik-exposed app at http://hello-go.local:8081/any/route

Any change in `src` dir will be synced to the k8s pod and the app will be rebuilt. Alternatively, you can use `local-hello-go-run` which will perform a one-time skaffold deploy and won't watch for file changes. 

## Cleanup

```
k3d delete -a
# uninstall tools
# remove repository
```

# Local environment for operators 

## Requirements

* Some [v]CPUs and 8gb+ of RAM are encouraged :)
* git
* [footlose]
* [ansible]

## Setup rio PaaS

```
ops-hello-go-up
```

## Usage

* Get k8s kubeconfig from footloose's k8s cluster
```
ops-hello-go-get-kubeconfig > /tmp/kubeconf
```
* Push production docker image to footloose's k8s cluster
```
export KUBECONFIG=/tmp/kubeconf
skaffold run -p rio-poc
```
* Update docker image in Riofile
```
# NOTE: we need to modify port 15000->5000 cos we have the footloose registry exported at 15000, but from k8s PoV, it's 5000
DOCKER_IMAGE=$(skaffold run -p rio-poc 2>/dev/null | grep -A1 'Tags used' | tail -n1 | awk '{print $NF}' | sed 's|registry.local:15000|regitry.local:5000|')
sed -i "s|image:.*|image: ${DOCKER_IMAGE}|" Riofile
```
* Deploy an autoscalable/canary-able app into rio
```
export KUBECONFIG=/tmp/kubeconf
rio up 
```
* Access the app at `localhost` by faking `Host` header to match rio's service FQDN:
```
curl -k -H 'Host: hello-go-v0-default.u92u9h.on-rio.io' http://localhost/hello-go-how-u-doin
```

## Cleanup

```
ops-hello-go-destroy
```

# TODO/improvements

* Use secure docker registry for every image (included k3s, etc to ensure deployment is reproducible from non-external resources)
* Improve kubeconfig/contexts integration with skaffold
* RBAC to allow developers to only use rio?
* Implement cucumber step definitions
* Use [inlets] instead of [ngrok]
* cucumber baids snippets (ruby implementation? it cleanly and elegantly integrates with shell calls :)

# NOTES

```
ansible-playbook -i ansible/hosts.ini ansible/site.yml --start-at-task "k3s : Copy k3s cluster setup script template"
kubectl tail -n rio-system # needs krew plugin: https://github.com/boz/kail
# registry.local resolves internally in the k8s cluster
rio run --scale 1-10 -p 80:3000 registry.local:5000/hello-go@sha256:7e7a4433134c0bc1f2fa422945c555bbd44db5f9ba93bd08ef6efa6d21dfbcce
hey -z 3m -c 500 http://hello-go-v0-default.u92u9h.on-rio.io/hello-go-how-u-doin
```

# Project tree

```
.
├── Dockerfile
├── README.md
├── Riofile
├── ansible
│   ├── group_vars
│   │   └── all
│   ├── hosts.ini
│   ├── roles
│   │   ├── common
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── docker
│   │   │   ├── files
│   │   │   │   └── docker-daemon.json
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── k3s
│   │   │   ├── files
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── templates
│   │   │       └── setup-k3s.sh.tpl
│   │   └── rio
│   │       ├── files
│   │       │   └── setup-rio.sh
│   │       └── tasks
│   │           └── main.yml
│   └── site.yml
├── baids
│   ├── 00-init
│   ├── 10-local-env
│   └── 10-ops-env
├── footloose.yaml
├── kubeconfig.yaml
├── kustomize
│   ├── base
│   │   ├── deployment.yaml
│   │   ├── kustomization.yaml
│   │   ├── namespace.yaml
│   │   └── service.yaml
│   ├── docker-registry
│   │   ├── helm-docker-registry.yaml
│   │   ├── kustomization.yaml
│   │   ├── ns-docker-registry.yaml
│   │   └── values.yaml
│   └── overlays
│       ├── local
│       │   ├── k3d-traefik-annotations.yaml
│       │   ├── kustomization.yaml
│       │   ├── ngrok-deployment.yaml
│       │   └── ngrok-service.yaml
│       └── staging
├── skaffold.yaml
└── src
    ├── README.md
    ├── api.go
    ├── api_test.go
    ├── api_test.go_DISABLED
    ├── features
    │   ├── godog_dependency_file_test.go
    │   └── main.feature
    ├── go.mod
    └── go.sum
```

[baids]: https://github.com/rcmorano/baids
[skaffold]: https://skaffold.dev/
[k3d]: https://github.com/rancher/k3d
[k3s]: https://k3s.io/
[kustomize]: https://kustomize.io/
[rio]: https://github.com/rancher/rio
[cucumber]: https://cucumber.io/
[godog]: https://github.com/cucumber/godog
[ngrok]: https://ngrok.com/
[ngrok-kubernetes]: https://github.com/abhirockzz/ngrok-kubernetes
[docker]: https://www.docker.com/
[footloose]: https://github.com/weaveworks/footloose
[jq]: https://stedolan.github.io/jq/
[inlets]: https://github.com/inlets/inlets
[ansible]: https://www.ansible.com/
[Riofile]: https://github.com/rancher/rio/blob/master/docs/riofile.md
[gin]: https://github.com/codegangsta/gin
