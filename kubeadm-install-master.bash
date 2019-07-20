#!/bin/bash

#Install kubeadm, kubectl & docker


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu kubelet=1.13.5-00 kubeadm=1.13.5-00 kubectl=1.13.5-00
sudo apt-mark hold docker-ce kubelet kubeadm kubectl
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf 
sudo sysctl -p

#Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=numCPU

#Steps to run kubectl as normal user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Apply Network Plugin

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

#Create Namespaces

kubectl create ns staging
kubectl create ns production

#Deploy Ingress Controller

curl -o get_helm.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get
chmod +x get_helm.sh
./get_helm.sh
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
sleep 90
helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true --set controller.publishService.enabled=true --namespace=kube-system

#Deploying application in Staging/Production namespaces

git clone https://github.com/kubernetes/examples.git
cd examples/guestbook
kubectl -n staging apply -f redis-master-deployment.yaml -f redis-master-service.yaml 
kubectl -n staging apply -f redis-slave-deployment.yaml -f redis-slave-service.yaml
kubectl -n staging apply -f frontend-deployment.yaml -f frontend-service.yaml
kubectl -n production apply -f redis-master-deployment.yaml -f redis-master-service.yaml 
kubectl -n production apply -f redis-slave-deployment.yaml -f redis-slave-service.yaml
kubectl -n production apply -f frontend-deployment.yaml -f frontend-service.yaml

#Expose application for Staging/Production namespaces

kubectl -n staging apply -f staging-frontend-ingress.yaml
kubectl -n production apply -f production-frontend-ingress.yaml 

#Implement HPA in Staging/Production Namespaces

kubectl -n production autoscale deployment frontend --cpu-percent=90 --min=1 --max=3
kubectl -n staging autoscale deployment frontend --cpu-percent=90 --min=1 --max=3