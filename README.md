mstakx-task-Level1

Run kubeadm-install-master.sh to install Kubeadm, Kubectl & Docker on master node along with Network Plugin after cluster initialization.

Once kubeadm-install-node script has run successfully on all worker nodes, run below command on each node to add it into the cluster.

Need to run as sudo:-

kubeadm join 10.128.0.8:6443 --token nclddz.bpn5mq03lxfscf2p --discovery-token-ca-cert-hash sha256:ddcbc91948ba83b0651a9d8bfaca1f35f7d3e9d92cb6a503237792a6456951d0

If you're unable to find the token, please run below command to generate a new one.

kubeadm token create --print-join-command

List of documentation followed for this task:-

https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports

https://cloud.google.com/community/tutorials/nginx-ingress-gke

https://github.com/helm/helm/blob/master/docs/install.md

https://itnext.io/save-costs-in-your-kubernetes-cluster-with-5-open-source-projects-7f53899a1429

https://medium.com/@nikkikokitkar/creating-kubernetes-clusters-using-kubeadm-f46d331a2405

Q. What was the node size chosen for the Kubernetes nodes? And why?

A. I've choosen a n1-standard-1 node with 1vCPU & 3.75GB memory as we're not running actual production traffic load on the server.Capacity of node will be decided once the L&P test will completed. 

Q. What method was chosen to install the demo application and ingress controller on the cluster, justify the method used.

A. I used kubectl to deply demo application. To deploy ingress controller , I used helm. Helm is one of the best tools to deploy application or cluster components as it takes care of dependencies.

Q. What would be your chosen solution to monitor the application on the cluster and why?

A. I will use tools like Instana, Prometheus, Grafana to monitor the application as well as cluster components.

Q. What additional components / plugins would you install on the cluster to manage it better?

A. I would go for plugins like Jenkins, Cluster Autoscaler & Vertical pod scaling. Also, in addition components like Prometheus, Grafana, ELK stack/Instana, can be used for betterment. Also will go for Calico as Network plugin.