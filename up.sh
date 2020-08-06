#!/bin/bash
multipass start k8s
multipass exec k8s -- sudo microk8s start
