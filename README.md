# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions-

Get your Azure Credentials and Create the VM Image with the help of packer
``Create a resource group name "DeployingWebserverInAzure" in portal Azure`` else it will say "Cannot locate the manage image resource group"

1. Login into azure - `az Login`
2. Create an rbac for loging in: az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription_id>"
Run -   `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/xxxx-xxxx-xxxx-xxxxxxxxxx"`
3. This Command will Output 5 values:

```sh
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "azure-cli-201-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

4. List your credentials- `az account show`

```sh
[
  {
    "cloudName": "AzureCloud",
    "id": "00000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "name": "PAYG Subscription",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000000",
    "user": {
      "name": "user@example.com",
      "type": "user"
    }
  }
]
```


5. These values map to the Terraform variables like so:

- appId is the client_id defined above.
- password is the client_secret defined above.
- tenant is the tenant_id defined above.
- subscription id is the id above

6. Set the ARM_environment variables

```sh
- $ export ARM_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
- $ export ARM_CLIENT_SECRET=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
- $ export ARM_SUBSCRIPTION_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
- $ export ARM_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
- $ export ARM_TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
```

8. create the image
Run -  `packer build server.json`
(It will create the image)

Note: Please check the path of the file server.json to run it without any error. Server.json file is the packer file.

Deploy the Infrastructure


1. Set the in TF_VAR_ environment variables or avoid defining it again and again.
```sh
$ export TF_VAR_subscription_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
$ export TF_VAR_client_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
$ export TF_VAR_client_secret=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
$ export TF_VAR_tenant_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
```

- Run `terraform init` 

2. Import the resource group state
run - `terraform import azurerm_resource_group.rg /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/DeployingWebserverInAzure`

3. Go to the directory where main.tf file is placed

4. Run `terraform plan -out solution.display`

5. Run `terraform apply solution.plan`

6. Run `terraform destroy`


Note - I have created a policy that ensures all indexed resources are tagged. This  helps with organization and tracking, and make it easier to log when things go wrong.


#### Output

The Output of Packer file-<br />
<img src="/Images/packer.png">


The Output of importing resource-<br />
<img src="/Images/imported.png">


The Output of plan command-<br />
<img src="/Images/plan.png">


The output of apply Command-<br />
<img src="/Images/Apply.png">


The output of destroy command -<br />
<img src="/Images/destroy.png">


The output of tagging-policy -<br />
<img src="/tagging-policy output/tagging-policy.png">


#### Customizing it for use -

The customizable variables are in var.tf file, you can change some variables like value i.e number of VMs, `change the value from “2” to the number of desired VMs`. After changing the value, run `terraform apply` again. You will get a new output. 

                                           Hope you liked this project :)
