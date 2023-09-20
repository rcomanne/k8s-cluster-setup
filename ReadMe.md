# k8s-cluster-setup
A repository for setting up a kubernetes cluster in Proxmox via Terraform.  
The nodes are based on Ubuntu 22.04 and will be running microk8s.

## Run
1. First, ensure you have a working Proxmox server/cluster setup and setup the required credentials for the [provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs).  
2. Create a basic Ubuntu VM via the Proxmox GUI and run the Ubuntu installer, this is so we get a template to clone from.
3. Add the name of the template vm to your variables and execute the Terraform files under `./terraform/infrastrcture`:  
    ```bash
    $ terraform init
    $ terraform plan -out infra.tfplan
    $ terraform apply infra.tfplan
    ```
4. Get a shell to the master node via PVE or your own local terminal, install microk8s and get the token for the worker nodes to join the cluster.
    ```bash
    # On the master node
    $ sudo snap install microk8s --classic
    $ sudo usermod -a -G microk8s $USER
    # Switch to the user to get the correct group applied
    $ su - $USER
    $ microk8s kubectl get nodes
    $ microk8s status
    $ microk8s add-node
    ```
5.  Ensure that the other nodes can be resolved, for this, add them to /etc/hosts
5. Go to your worker node(s), install microk8s and run the provided command with the token:
   ```bash
    $ sudo snap install microk8s --classic
    $ sudo usermod -a -G microk8s $USER
    # Switch to the user to get the correct group applied
    $ su - $USER
    $ microk8s join <IP>:25000/<TOKEN> --worker
   ```