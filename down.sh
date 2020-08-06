#!/bin/bash
multipass exec k8s -- sudo microk8s stop
multipass stop k8s
