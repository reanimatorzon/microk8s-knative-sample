#!/bin/bash
read -r -p "This destroys your current 'k8s' machine! Proceed? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

    ./delete.sh 2&>/dev/null

	multipass launch --name k8s --cpus 4 --mem 20G --disk 40G
	multipass exec k8s -- sudo snap install microk8s --classic

	./up.sh

	multipass exec k8s -- sudo microk8s config > ~/.kube/config
	multipass exec k8s -- sudo usermod -a -G microk8s ubuntu
	multipass exec k8s -- sudo chown -f -R ubuntu ~/.kube

	multipass exec k8s -- sudo microk8s enable dns istio # dashboard

	./wait.sh

	kubectl apply -f https://github.com/knative/operator/releases/download/v0.16.0/operator.yaml
	kubectl label namespace default istio-injection=enabled

	./wait.sh

	kubectl apply -f ./knative-serving.yaml

	./wait.sh

	until kubectl patch cm config-domain --namespace knative-serving -p '{ "data": { "127.0.0.1.xip.io": "" } }'; do sleep 1; done;
	
	# ...contraversal is `kubectl label namespace default istio-injection-`

	# kubectl apply -f ./knative-eventing.yaml
	#TODO: kubectl apply -f ./knative-monitoring.yaml

	kubectl apply -f ../tmp/kn-rest-api/knative-docs/docs/serving/samples/hello-world/helloworld-go/service.yaml

	./wait.sh

	watch -n 10 multipass exec k8s -- curl -I -HHost:helloworld-go.default.127.0.0.1.xip.io http://localhost:31380/

fi
