# Commissioning Redpanda Brokers

*Here is a [link to our docs](https://docs.redpanda.com/current/manage/kubernetes/decommission-brokers/) on this topic.*

This scenario focuses on commissioning (adding/removing) brokers.

A popular reason for increasing a cluster's broker count is to expand the cluster's available resources. Conversely, a popular reason for decreasing the broker count is to save money on infrastructure costs over time. But this process should only be taken after considering several factors:

- Availability: do you have enough brokers to span across all racks and/or availability zones?
- Cost: infrastructure costs will be impacted by a change in broker count
- Data retention: storage capacity and possible retention values are determined in large part by the local disk capacity across all brokers
- Durability: you should have more brokers than your lowest partition replication factor
- partition count: this value is determined primarily by the CPU core count of the overall cluster

One of the most common reasons for decommissioning brokers is upgrading Kubernetes, which is done by replacing the nodes Redpanda pods run on with ones from a new node pool.

## Prerequisites

Run through the prerequisites and steps for creating a cluster as shown in [scenario 0](../0-cluster-setup/README.md).

## Overview

This guide walks through the process of moving pods of a Redpanda deployment from one node pool to another. This is an infrequent process that is the basis for some maintenance tasks, such as upgrading Kubernetes in your cluster.

These are the steps at a high level:

1. [Create new node pool](#create-a-new-node-pool)
2. [Tune new nodes](#tune-new-nodes)
3. [Update Redpanda deployment](#update-statefulset)
4. [Move Redpanda](#move-redpanda-pods-to-new-nodes)

## Create a new node pool

Run the following command to create a new node pool:

```
az aks nodepool add -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME -n nodepool2 --enable-node-public-ip --node-vm-size Standard_L8s_v3 --kubernetes-version 1.26.6
```

This command will create a new node pool named 'nodepool2' for your cluster and located in the same resource group. A Kubernetes version is given, which is the default version at the time of this writing.

Taint these nodes with a 'redpanda' parameter so that the helm chart will have a way to know these are the preferred nodes. First get the list of nodes:

```
kubectl get node -o wide
```

Example output:

```
NAME                                STATUS   ROLES   AGE     VERSION   INTERNAL-IP   EXTERNAL-IP      OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-51376000-vmss000000   Ready    agent   7d22h   v1.26.6   10.224.0.4    172.202.90.125   Ubuntu 22.04.3 LTS   5.15.0-1051-azure   containerd://1.7.5-1
aks-nodepool1-51376000-vmss000001   Ready    agent   7d22h   v1.26.6   10.224.0.5    172.202.90.132   Ubuntu 22.04.3 LTS   5.15.0-1051-azure   containerd://1.7.5-1
aks-nodepool1-51376000-vmss000002   Ready    agent   7d22h   v1.26.6   10.224.0.6    172.202.90.141   Ubuntu 22.04.3 LTS   5.15.0-1051-azure   containerd://1.7.5-1
aks-nodepool2-12587716-vmss000000   Ready    agent   9m15s   v1.26.6   10.224.0.8    13.89.200.215    Ubuntu 22.04.3 LTS   5.15.0-1051-azure   containerd://1.7.5-1
aks-nodepool2-12587716-vmss000001   Ready    agent   9m1s    v1.26.6   10.224.0.7    13.89.200.221    Ubuntu 22.04.3 LTS   5.15.0-1051-azure   containerd://1.7.5-1
aks-nodepool2-12587716-vmss000002   Ready    agent   9m      v1.26.6   10.224.0.9    13.89.200.118    Ubuntu 22.04.3 LTS   5.15.0-1051-azure   containerd://1.7.5-1
```

In the above output there are six nodes, and the bottom three are part of the new nodepool. Run the following command to taint and add a label to each of the three new nodes for Redpanda:

```
kubectl taint node -l agentpool=nodepool2 redpanda=true:NoSchedule
kubectl label node -l agentpool=nodepool2 nodetype=redpanda
```

> Note: The above command assumes you used 'nodepool2' for the name of your node pool (update as needed).

## Tune new nodes

Follow the same steps in the cluster setup [here](../0-cluster-setup/README.md#tune-kubernetes-nodes) to tune the newly added nodes

## Update StatefulSet

The StatefulSet resource controls the deployment of pods where Redpanda brokers run. The existing StatefulSet needs to be reconfigured so that it only schedules pods on the new Kubernetes nodes (based on the taint configured above).

First delete the existing StatefulSet:

```
kubectl delete sts redpanda -n redpanda --cascade=orphan
```

The `--cascade=orphan` flag says to keep the existing pods running (in spite of the controlling StatefulSet being deleted).

Now replace the StatefulSet with a new one that ensures Redpanda pods will only be assigned to appropriate nodes:

```
helm upgrade redpanda redpanda --repo https://charts.redpanda.com -n redpanda --wait -f values-1-broker-mgmt.yaml --reuse-values
```

The `values-1-broker-mgmt.yaml` file includes a change to the update strategy for pods so the new StatefulSet doesn't immediately start deleting pods. We will do this manually to account for the need to delete the persistent volume claim (PVC) and also to verify cluster health along the way.

## Move Redpanda pods to new nodes

List the persistent volume claims (PVCs) for the cluster:

```
kubectl get pvc -n redpanda -o wide
```

The following steps need to be taken for each Redpanda pod:

Delete the PVC associated with the last pod in the cluster (in this case `redpanda-2`)

```
kubectl delete pvc datadir-redpanda-2 -n redpanda --wait=false
```

The `--wait=false` flag tells Kubernetes to not actually delete the PVC until the associated pod is delete.

Delete the associated pod:

```
kubectl delete pod redpanda-2 -n redpanda
```

Follow the broker logs as Redpanda reacts to the broker loss:

```
stern -A --init-containers=false "redpanda-\d"
```

Eventually logs will slow down but the cluster will remain in an unhealthy state with 1 of 2 containers within each pod available. This can be verified with the following command:

```
rpk cluster health
```

The broker ID associated with the deleted pod (in this case '2') will be down, and it will still be part of the cluster. Decommission this broker to remove it from the cluster:

```
rpk redpanda admin brokers decommission 2 --force
```

Now the cluster will soon become healthy again:

```
rpk cluster health
```

Repeat the above steps for each pod in the Redpanda cluster.

