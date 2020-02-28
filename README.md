# Solution overview

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

## Features

* Allows local development to be as similar as possible across other environments
* Allows iterable development by using Behaviour Driven Development where requirements are expressed in a natural language between all the stakeholders
* Allows local environment to be publicly shared via HTTPS (thx ngrok!)
* GitOps enabled
* Easy autoscaling enabled (thx rio!)
* Canary deploys enabled (thx rio!)

# Setup local develop enviroment

## Requirements

* git
* curl
* bash/zsh (bash recommended)
* [jq]

## Install snippet

When run from the root of this repository, this copy+paste snippet should cleanly install all the necessary tools for the local environment setup:

```
# Clone this repository (tho this makes no sense since this is being shipped as a zip)
# git clone $GIT_REPO_URL ~/Projects/typeform/hello-typeform
# install baids
curl -sSL https://raw.githubusercontent.com/rcmorano/baids/master/baids | bash -s install
ln -s ${PWD}/baids ${HOME}/.baids/functions.d/hello-typeform
baids-reload
local-hello-typeform-setup
```

## Usage

From project root run:
```
skaffold dev -p local
```

Then any change  

## Cleanup

```
k3d delete -a
# uninstall tools
# remove repository
```

# TODO

*

# Improvements

* Use [inlets] instead of [ngrok]

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
