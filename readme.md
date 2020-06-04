![](https://github.com/rohitgabriel/eks-node-groups/workflows/Terraform/badge.svg)

## Build EKS
Uses Nodegroups<br/>

aws eks --region ap-southeast-2 update-kubeconfig --name eks --kubeconfig kubeconfig
https://docs.aws.amazon.com/eks/latest/userguide/eks-guestbook.html
https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

## Upgrade Notes:
Bump up the variables in this repo
eks_version
nodegroup_ami_version

Upgrade kube-proxy:
kubectl get daemonset kube-proxy --namespace kube-system -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
kubectl set image daemonset.apps/kube-proxy \
    -n kube-system \
    kube-proxy=602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/kube-proxy:v1.16.8

Upgrade kube-dns:
kubectl get pod -n kube-system -l k8s-app=kube-dns
kubectl describe deployment coredns --namespace kube-system | grep Image | cut -d "/" -f 3
kubectl get deployment coredns --namespace kube-system -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
kubectl set image --namespace kube-system deployment.apps/coredns \
            coredns=602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/coredns:v1.6.6

Upgrade VPC CNI plugin:
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.6/aws-k8s-cni.yaml


