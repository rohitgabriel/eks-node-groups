![](https://github.com/rohitgabriel/eks-node-groups/workflows/Terraform/badge.svg)

## Build EKS
Uses Nodegroups<br/>
Autoscaler works


aws eks --region ap-southeast-2 update-kubeconfig --name eks --kubeconfig kubeconfig
https://docs.aws.amazon.com/eks/latest/userguide/eks-guestbook.html
https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

## Build EKS second cluster
Add modules for cluster and nodegroup
Add a subnet tag line in vpc
Update new variable

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

Bug: https://github.com/terraform-providers/terraform-provider-aws/issues/12675


----
https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/
https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
git clone https://github.com/kubernetes-sigs/aws-efs-csi-driver.git
https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes/multiple_pods/specs
cd aws-efs-csi-driver/examples/kubernetes/multiple_pods/
aws efs describe-file-systems --query "FileSystems[*].FileSystemId" --output text
kubectl apply -f specs/

ROADBLOCKER!! https://github.com/hashicorp/terraform-provider-kubernetes/issues/296
---
Autoscaler
https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html
https://github.com/helm/charts/tree/master/stable/cluster-autoscaler
https://console.cloud.google.com/storage/browser/_details/kubernetes-charts
https://aperogeek.fr/kubernetes-deployment-with-terraform/
        automountServiceAccountToken = "true"
---
linkerd
https://www.devopsfu.com/2020/01/17/automating-linkerd-installation-in-terraform/