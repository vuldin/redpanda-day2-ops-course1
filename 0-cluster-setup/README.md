# AKS cluster setup

These steps will walk through creating an AKS cluster that is ready for deploying Redpanda.

### Prerequisites

Clone this repo and switch to the proper branch. This repo contains files that will be used in many of the commands provided below:

```
git clone https://github.com/vuldin/redpanda-day2-ops-course1.git
git checkout k8s
```

You will need the Azure CLI `az` installed and connected to your account. More details on installing `az` are [here](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli#prerequisites).

[Redpanda Keeper (rpk)](https://docs.redpanda.com/current/get-started/intro-to-rpk/) is Redpanda's CLI. Follow [these instructions](https://docs.redpanda.com/current/get-started/rpk-install/) to install the tool.

[Stern](https://github.com/stern/stern) is a powerful tool for tailing logs across multiple pods (such as all Redpanda brokers) at the same time. Download the latest binary for your platform from [their releases](https://github.com/stern/stern/releases) page and extract it to a directory in your path.

[yq](https://mikefarah.gitbook.io/yq/) is a yaml processing CLI. See the [install section](https://github.com/mikefarah/yq/#install) of their docs for more details.

Define some environment variables with appropriate values for your current environment:

```
RESOURCE_GROUP=<resource group name>
REGION=<region name>
CLUSTER_NAME=<cluster name>
REDPANDA_DOMAIN=<domain for your Redpanda brokers>
```

## Create the cluster

Create the resource group defined above:

```
az group create --name $RESOURCE_GROUP --location $REGION
```

Create an AKS cluster inside the resource group:

```
az aks create -g $RESOURCE_GROUP -n $CLUSTER_NAME --generate-ssh-keys --ssh-key-value ~/.ssh/$CLUSTER_NAME.pub --enable-node-public-ip --node-vm-size Standard_L8s_v3 --disable-file-driver
```

> Note: The above command will create a private key (`~/.ssh/$CLUSTER_NAME`) and public key (`~/.ssh/$CLUSTER_NAME.pub`), which will be used to SSH into the Kubernetes nodes.

> Note: The flag `--disable-file-driver` disables the default CSI driver for this cluster. This is because we will install a local volume manager (LVM) CSI driver that will allow us to make use of the local NVMe disks available in the `Standard_L8s_v3` instance type. See [our docs](https://docs.redpanda.com/current/deploy/deployment-option/self-hosted/kubernetes/aks-guide/#create-sc) for more details.

> Note: The VM `Standard_L8s_v3` is the smallest of the Lsv3-series. More details [here](https://learn.microsoft.com/en-us/azure/virtual-machines/lsv3-series). For more details on our recommended AKS VMs, see [our docs](https://docs.redpanda.com/current/deploy/deployment-option/self-hosted/kubernetes/cloud-instance-local-storage/#azure-aks).

Update kubeconfig to be able to connect to the cluster:

```
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## Update firewall

Add an inbound security rule that allows you to connect via SSH to each node:

1. Search for 'Network security groups' in [Azure Portal](https://portal.azure.com/).
2. Select the network security group associated with the resource group created in the steps above (same as the environment variable $RESOURCE_GROUP).
3. Select 'Inbound security rules', then select '+ Add'
3. Add an inbound security rule with destination port set to `22`, and save.

> Note: For production environments, the source value for the above rules should be set to prevent the ports from being open to all connections.

## Tune Kubernetes nodes

There are some tuning steps that need to be performed on each Kubernetes node. For more details on these steps, see these links to our docs:

- https://docs.redpanda.com/current/deploy/deployment-option/self-hosted/kubernetes/kubernetes-tune-workers
- https://docs.redpanda.com/current/reference/rpk/rpk-redpanda/rpk-redpanda-tune/

Find the external IP addresses of each node:

```
kubectl get nodes -o wide
```

Run the following command for each external IP address

```
ssh azureuser@10.12.0.1 -o IdentitiesOnly=yes -i ~/.ssh/$CLUSTER_NAME '\
curl -sLO https://gist.githubusercontent.com/vuldin/0c8bf87f188ba1fe6854dac17ec9ff10/raw/redpanda-tune-k8s-node.sh;\
chmod +x redpanda-tune-k8s-node.sh;\
./redpanda-tune-k8s-node.sh'
```

> Note: We are improving the process for tuning Kubernetes nodes, stay tuned for more details.

## Configure storage

Install the LVM CSI driver and wait for the pods to be ready:

```
helm install csi-driver-lvm csi-driver-lvm --repo https://helm.metal-stack.io -n csi-driver-lvm --create-namespace --set lvm.devicePattern='/dev/nvme[0-9]n[0-9]'
kubectl wait -n csi-driver-lvm --for=condition=ready pod --selector=app=csi-driver-lvm-plugin --timeout=90s
```

Apply the StorageClass resource defined in the file `csi-driver-lvm-striped-xfs.yaml`:

```
kubectl apply -f csi-driver-lvm-striped-xfs.yaml
```

For more details on the above resource definition, see step 2 in [this page](https://docs.redpanda.com/current/deploy/deployment-option/self-hosted/kubernetes/aks-guide/#create-sc) of our docs.

## Prepare TLS certificates

By default, Redpanda helm deployments will generate a self-signed TLS certificate with [cert-manager](https://cert-manager.io/). But in a production environment you will likely already have TLS certificates.

Take the following steps to use your own certificates (and not require `cert-manager` as a dependency).

If you have your own certificates, then the instructions below assume your certificates are in the following location (in the current directory):

- `certs/ca.crt`: CA certificate
- `certs/node.key`: broker TLS key
- `certs/node.crt`: broker TLS certificate

> Note: Make sure your certificates have proper DNS names for your Redpanda brokers.

If you do not have your own certificates, then the provided `generate-certs.sh` script will generate cert files in the locations listed above.

```
./generate-certs.sh $REDPANDA_DOMAIN
```

> Note: If you used the domain `my-company.com` as `$REDPANDA_DOMAIN` in the command above, then your TLS certificates will work for the wildcard address `*.my-company.com`. The Redpanda helm deployment will also be configured to use this same domain.

Now that the certificate files are in the appropriate location, generate a Kubernetes secret making use of these file in the format the Redpanda helm chart expects:

```
kubectl create ns redpanda
kubectl create secret generic tls-external --from-file=ca.crt=certs/ca.crt --from-file=tls.crt=certs/node.crt --from-file=tls.key=certs/node.key --dry-run=client -o yaml > tls-external.yaml
kubectl apply -f tls-external.yaml -n redpanda
```

## Prepare SASL users

Run the following command to generate `superusers.txt` with details for your superuser:

```
echo 'username:password:SCRAM-SHA-256' > superusers.txt
```

Replace `username` and `password` in the command above with your chosen username/password.

Create a Kubernetes secret based off the generated `superusers.txt` and then delete the file:

```
kubectl create secret generic redpanda-superusers -n redpanda --from-file=superusers.txt
rm superusers.txt
```

The `redpanda-superusers` secret will be referenced in the helm deployment config below.

## Prepare tiered storage

Create a storage account:

1. Search for and select 'Storage accounts', then click '+ Create'
2. Choose the resource group you created earlier from the dropdown(value of $RESOURCE_GROUP), set your account name (must be globally unique), make sure the proper region is selected (same as the cluster), and select 'Review' and then 'Create'
3. Click 'Go to resource', then select 'Containers' under 'Data storage'
4. Click '+ Container', then name the container and select 'Create'
4. Get the associated keys with `az storage account keys list --resource-group $RESOURCE_GROUP --account-name yourstorageaccount` (replace 'yourstorageaccount' with your details). There will be multiple keys, you can use either.

> Note: The storage account, a shared key, and container values would normally be used to update the helm chart `values.yaml`. Due to [a helm chart regression](https://github.com/redpanda-data/helm-charts/issues/871), we will instead apply tiered storage config via `rpk` once the cluster is up and running.

Run the following commands to keep track of these variables for subsequent steps:

```
STORAGE_ACCOUNT=yoursa
TS_SHARED_KEY=yourkey
TS_CONTAINER=yourcontainer
```

## Deploy Redpanda

The provided `values-0-setup.yaml` file is the helm chart config that will make use of the steps taken above to configure the following:

- SASL authentication (and the `redpanda-superusers` secret)
- TLS encryption (the external domain and `tls-external` secret)
- Persistent volume using the created StorageClass resource `csi-driver-lvm-striped-xfs`
- * Tiered storage connected to the bucket created above
- Console configured to connect as an internal client

Deploy Redpanda using the above config file with the following command:

```
helm install redpanda redpanda --repo https://charts.redpanda.com -n redpanda --wait -f values-0-setup.yaml
```

## Update DNS

The `values-0-setup.yaml` file has the following external section:

```
external:
  enabled: true
  type: LoadBalancer
  domain: local
```

This sets the external domain for each brokers to `local` by default. This config also set `external.type` to `LoadBalancer`, which will deploy an application load balancer service for each broker. These services will be assigned external IP addresses, and these IP addresses must be resolvable by the following hostnames:

- `redpanda-0.local`
- `redpanda-1.local`
- `redpanda-2.local`

You can get the IP addresses for each of these LoadBalancer services with the following command:

```
kubectl get svc -n redpanda -o yaml | yq '.items[].status.loadBalancer.ingress[].ip'
```

Updating DNS can take time to propogate, and each organization has different DNS providers and related configuration steps. For this guide we will add the above hostnames/IP combinations to `/etc/hosts` in order ensure they are quickly resolvable for our testing.

Add the above IP addresses and broker hostnames to your hosts file:

```
sudo vi /etc/hosts
```

Both the subdomain and domain for the brokers is customizable. For instance if you wanted your brokers to be available at `apple.breakfast.com`, `bacon.breakfast.com`, and `carrot.breakfast.com`, you would use the following configuration:

```
external:
  enabled: true
  type: LoadBalancer
  domain: breakfast.com
  addresses:
  - apple
  - bacon
  - carrot
```

### Note on external-dns

`external-dns` is the recommended way to keep your DNS records updated. More details on how to do this within Azure are [here](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md) and [here](https://docs.redpanda.com/current/manage/kubernetes/networking/configure-external-access-loadbalancer/#externaldns).

## Connect via broker rpk

`rpk` can be used from within any broker to test connectivity, check cluster health, and verify configuration. The following command lists each broker and its internally advertised hostname:

```
kubectl exec -it -n redpanda redpanda-0 -c redpanda -- rpk cluster info --brokers localhost:9093 --user username --password password
```

Changing to port 9094 lists each broker's externally advertised hostname:

```
kubectl exec -it -n redpanda redpanda-0 -c redpanda -- rpk cluster info --brokers localhost:9094 --tls-enabled --tls-truststore /etc/tls/certs/external/ca.crt --user username --password password
```

> Note: External clients will connect to the cluster using TLS and SASL.

## Connect via local rpk

Create an rpk profile for connecting to Redpanda from your locally installed CLI:

```
rpk profile create az-admin -s brokers=redpanda-0.local:31092 -s tls.ca="$(realpath ./certs/ca.crt)" -s admin.hosts=redpanda-0.local:31644 -s kafka_api.sasl.user=username -s kafka_api.sasl.password=password -s kafka_api.sasl.mechanism=SCRAM-SHA-256
```

`rpk` can now connect to the cluster. Run the following commands to verify external advertised listeners and cluster health:

```
rpk cluster info
rpk cluster health
```

## Enable tiered storage via rpk

Run the following commands from your local `rpk` to enable tiered storage:

```
rpk cluster config set cloud_storage_enabled true
rpk cluster config set cloud_storage_azure_container $TS_CONTAINER
rpk cluster config set cloud_storage_azure_shared_key $TS_SHARED_KEY
rpk cluster config set cloud_storage_azure_storage_account $STORAGE_ACCOUNT
```

The cluster will need to be restarted for the above changes to take affect. This can be done by rolling out a restart via the Redpanda Statefulset resource:

```
kubectl rollout restart sts redpanda -n redpanda
```

You can monitor the restart process with stern, which tails logs across all brokers:

```
stern -A --init-containers=false "redpanda-\d"
```

### Verify tiered storage

Once the cluster has restarted, we can verify tiered storage by generating enough data in an appropriately configured topic to start pushing data to the bucket.

Create a test topic that is backed by tiered storage:

```
rpk topic create tslog -c redpanda.remote.read=true -c redpanda.remote.write=true
```

Use your local `rpk` to generate a sizeable amount of data into the topic:

```
BATCH=$(date); printf "$BATCH %s\n" {1..1000000} | rpk topic produce tslog
```

Open the container in Azure portal to see remote segment objects:

1. Open [Azure portal](https://portal.azure.com/) and search for 'Storage accounts', then select your recently created storage account.
2. Select 'Containers' under 'Data storage' on the left.
3. Select your recently created container and verify folder exist (for example, multiple folders with one named `4000000`)

## Continue with scenarios

The cluster is now ready for the subsequent scenarios!

## Cleanup

Delete the helm deployment:

```
helm uninstall redpanda -n redpanda
```

Delete the AKS cluster:

```
az aks delete -n $CLUSTER_NAME -g $RESOURCE_GROUP
```

Delete the resource group:

```
az group delete --name $RESOURCE_GROUP
```

Delete the TLS certificates:

```
./delete-certs.sh
```

