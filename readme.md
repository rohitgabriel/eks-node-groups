![](https://github.com/rohitgabriel/eks-node-groups/workflows/Terraform/badge.svg)

## Build EKS
Uses Nodegroups<br/>

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
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

20s         Warning   FailedScheduling   pod/app2   pod has unbound immediate PersistentVolumeClaims (repeated 3 times)
16s         Normal    Scheduled          pod/app2   Successfully assigned default/app2 to ip-10-0-85-128.ap-southeast-2.compute.internal
7s          Warning   FailedMount        pod/app2   MountVolume.SetUp failed for volume "efs-pv1" : kubernetes.io/csi: mounter.SetupAt failed: rpc error: code = Internal desc = Could not mount "fs-c952b1f1:/" at "/var/lib/kubelet/pods/dc4ee7f5-3fd3-4d87-9701-608de801c3a8/volumes/kubernetes.io~csi/efs-pv1/mount": mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t efs fs-c952b1f1:/ /var/lib/kubelet/pods/dc4ee7f5-3fd3-4d87-9701-608de801c3a8/volumes/kubernetes.io~csi/efs-pv1/mount
Output: mount.nfs4: access denied by server while mounting fs-c952b1f1.efs.ap-southeast-2.amazonaws.com:/