# Terraform OCI Provider

Terraform module template for OCI provider. Example for creating VCN, compute, and block.
Terraform OCI provider was updated to 3.5.0.
Terraform v0.12.24

## Before We Begin

There are two ways to deploy the terraform scripts:
- Resource Manager : OCI provides a service to run Terraform scripts from Oracle Cloud Console
- Local Machine: You can install Terraform and run Terraform commands to deploy configuration 

## Prerequisites

Have the following setup and created before running terraform: 
- Create a Compartment to run the deployment
- Create Public IPs you'll attach to Bastion, EDQ, and SFTP server


## Deployment 

**Resource Manager**:  If you are using Resource Manager you can zip the folder and create a new stack. 
During the configuration it will ask you for the parameters and input each one. 
*Note* You cannot auto attach Public IPs already created if you use resource manager. You have to use terraform import command. 

Variables you will need to get for the Resource Manager Stack: 
```
tenancy_ocid = [OCID of the tenancy]
root_compartment_ocid = [OCID of the destination compartment] 
compartment_ocid = [OCID of working compartment]
availability_domain = [value from 0-2]
fault_domain = [value from 1-2]
ssh_public_key = [Public keys]
```
The stack will also ask for other variable configurations for the environment. 

Skip to [Follow Up - Manual Configurations](##_Follow_Up_-_Manual_Configurations_) for manual setup after terraform is finished. 

### Attaching Pre-Existing Public IPS (Terraform Import. SKIP if using Resource Manager)
 
Attached already created reserved IP information [here](https://github.com/terraform-providers/terraform-provider-oci/issues/840)

1. First create a resource for the public IPs. There is a sample in sandbox.tf (main file) 
```
resource "oci_core_public_ip" "TFpublic_ip" {
     #Required
     compartment_id = var.compartment_ocid
     lifetime = "RESERVED"
     display_name = "${var.prefix}_sftp_ip"
     private_ip_id = data.oci_core_private_ips.TFprivate_ips_by_vnic.private_ips[0].id
 }
# Need to find the id for the specific private IP on the S
data "oci_core_private_ips" "TFprivate_ips_by_vnic" {
     ip_address = module.sftp_env.private_ip
     subnet_id = module.env_subnets.public_subnet_ocid
}
```
Make sure you get the right private IP for the compute you want to attach the public IP to. 

2. Use terraform import to get the Existing Public IP
Log into the OCI Console and get the OCID of the public IP
```
terraform import oci_core_public_ip.TFpublic_ip "<OCID of PUblic IP>"
```

3. Repeat the same steps for the other two Public IPs. Run the terraform scripts as normal. 

## Running Terraform - Variables Needed for Configuration

We need to create a file called `terraform.tfvars`. This file will contain sensitive information used to authenticate ourselves to the OCI.

```
tenancy_ocid = [OCID of the tenancy]
region = [Region of tenancy] 
# compartment_ocid should be root ocid used for Marketplace image
root_compartment_ocid = [OCID of the destination compartment] 
compartment_ocid = [OCID of working compartment]
availability_domain = [value from 0-2]
fault_domain = [value from 1-2]
ssh_public_key = [Public keys]

prefix = [Prefix for all the resources.]
vcn_cidr = [CIDR block for VCN example: 10.0.0.0/16]
public_subnet_cidr = [CIDR for public subnet]
db_subnet_cidr = [CIDR for database]

db_size = [Database size must be in gb: 256, 512, 1024, 2048, 4096 GB]
edq_size = [Storage size in GB. Minimum 50 GB]
sftp_size = [Storage size in GB. Minimum 50 GB]
bastion_size = [Storage size in GB. Minimum 50 GB]

db_shape = [Shape for compute. Example: VM.Standard2.1, VM.Standard2.2]
edq_shape = [Shape for compute. Example: VM.Standard2.1, VM.Standard2.2]
sftp_shape = [Shape for compute. Example: VM.Standard2.1, VM.Standard2.2]
bastion_shape = [Shape for compute. Example: VM.Standard2.1, VM.Standard2.2]

db_edition = [Database edition: STANDARD_EDITION, ENTERPRISE_EDITION, ENTERPRISE_EDITION_EXTREME_PERFORMANCE, or ENTERPRISE_EDITION_EXTREME_PERFORMANCE.]
db_version = [Versions available 11.2.0.4, 12.1.0.2, 12.2.0.1, 18.0.0.0, 19.0.0.0]
db_hostname = [ Hostname. Cannot be longer than 8 characters. Starts with a letter.]
db_main_name = [Cannot be longer than 8 characters. Starts with a letter.]
db_pdb_name = [Cannot be longer than 8 characters. Starts with a letter.]
db_admin_password = [ Admin password. Must be longer than 12 characters. Passwords can contain only alphanumeric characters and the underscore (_), dollar sign ($), and pound sign (#). Requires 2 uppercase, 2 lowercase, 2 symbols, and 2 numbers.]

fs_mount_path_folder = [Path Folder for FSS mount. Required: Add '/' infront.]

boot_volume_policy_version = [Policy for boot volumes automatic backups.]

//Following not needed if using Resource Manager
ssh_private_key_path = [Path to private ssh key]
private_key_path= [Path to OCI private key file]
fingerprint = [Fingerprint of OCI public key added to user]
user_ocid = [OCID of the OCI user. We used api.user]
```

These values are passed onto `vars.tf` and is mainly used in `main.tf`.

__Uncomment the following in vars.tf, provider.tf:__
//Following not needed if using Resource Manager
variable private_key_path {} 
variable fingerprint {}
variable ssh_private_key_path {}
variable user_ocid {}

### Run commands

Following commands used to run the terraform scripts
1. Initialize the Terraform Scripts
```
$ terraform init
```
2. Run a Terraform Plan to test configuration
3. Run Terraform Apply to actually deploy
```
$ terraform plan
$ terraform apply
```

## Terraform Structure

We split our Terraform project into modules, which can be thought of as smaller Terraform functions. A module will be in its own separate folder in the `modules` directory.

```
main.tf
vars.tf
provider.tf
terraform.tfvars
modules
 |
 |---- compartment
 |---- vcn  
 |---- compute
 |---- objectstorage
 |---- file_storage
 |---- database

```

In `main.tf` we run each module sequentially, starting with the `vcn` module, and ending with the `compute` module. Here is a brief description of what each module does.

`vcn` - Creates a new virtual cloud network, internet gateway, and a subnet with a security list

`compute` - Create a new instance. 

## Step 0: Configuring the Provider and Main File

Don't forget to configure your `terraform.tfvars` file beforehand!

In this step we will set up our `provider.tf` file to allow us to authenticate into OCI. If we did not have this file, then we would have to run our authentication code for every module we run. This way, we only need to authenticate once. Read the `provider.tf` [file](provider.tf) for a better idea on how to format it. For more information, click [here](https://www.terraform.io/docs/configuration/providers.html) (Note: this link uses AWS in their examples).

Our `main.tf` [file](main.tf) is what we will use to run all our modules. Every time we want to add a module we use this block:

```
module "module_name_1" {
  source = [insert path to folder of module]
  example_variable_1 = var.example_variable_1
  example_variable_2 = "hard coded variable"
  example_variable_3 = module.example_module.example_output_variable
}
```
In this code we set a path to the module and pass in variables the module requires. These variables should be set beforehand `vars.tf` and `terraform.tfvars` (especially if they are sensitive) but you can also hard code them like in `example_variable_2`. There is an example of how to pass in external variables outputted by a module in `example_variable_3`. We will get to that later.

To initialize the Terraform project, call `terraform init` on your command line. To see how the project would change your OCI infrastructure call `terraform plan`. To apply these changes, run `terraform apply`


## Step 1: Creating the VCN

Our code for creating a VCN and subnet was adapted using the template found [here](https://gist.github.com/lucassrg/9b97fb224cb4882d7db6b04a5b048ea8). We open port 80, 3000, 5000, and 1521 because our web application we would migrate needs them. 

In `main.tf` we pass the variables `user_ocid`, `tenancy_ocid`, `compartment_ocid`, `ssh_public_key_path`, `ssh_private_key_path`, `fingerprint`, `region`, and `availability_domain`. 

***IMPORTANT:*** We have hard-coded our `region` variable as "ad-ashburn-1." If your tenancy is in, for example, "us-phoenix-1", then you must change the value of `region`. Furthermore, we have decided as a preference to zero-index our availability domains. For example AD-1 is mapped to 0, AD-2 to 1, and AD-2 to 2. Therefore, since we want to use AD-1, our `availability_domain` variable returns 0.

### A Brief Intro to Output Variables

In `modules/vcn` we also have an `outputs.tf` [file](/modules/vcn/outputs.tf). We are outputting a variable called `subnet_ocid` which we will use later when we compute an instance. This is very helpful, because without the ability to output variables, we would have to run the vcn module, pause to find OCID of the subnet we just created, manually pass it to our compute module, and then run the compute module. By outputting the variable, we can run modules one after another even if one module is dependent on another module. Terraform will understand there is an implicit dependency between those modules (you cannot yet state explicit dependencies between module). We can reference the `subnet_ocid` variable in `main.tf` as `modules.vcn.subnet_ocid`. We will use more output variables later in the tutorial. Read more about output variables [here](https://www.terraform.io/intro/getting-started/outputs.html)

Also learn more about dependencies [here](https://www.terraform.io/intro/getting-started/dependencies.html). They're also important to know!

## Step 2: Creating a Compute Instance and rest of environment

Finally, we create the compute mostly using code from Abhiram Ampabathina [here](https://github.com/mrabhiram/terraform-oci-sample/tree/master/modules/compute-instance) (we barely wrote any original code as you can probably tell, but we never really tread any new ground that required new code. As long as you have a good understanding of Terraform, we believe it's okay. And even if you don't, looking at example code is a good way to learn ☺️).

Note: For market place image used the following for reference [here](https://github.com/terraform-providers/terraform-provider-oci/blob/master/examples/marketplace/main.tf)

Remote exec reference: [here](https://medium.com/oracledevs/automating-instance-initialization-with-terraform-on-oracle-cloud-infrastructure-part-2-e1aa1a8710d)

## Conclusion
It has been made clear through this lab how powerful and useful Terraform is for DevOps and cloud developers. We hope this walkthrough was useful!

## Follow Up - Manual Configurations 

1. Attach the Reserved Public IP to the instances if using Resource Manager
2. Set up SFTP server 
3. Configure EDQ with the database and setup going to the http://<EDQ_IP>/setup
4. Import EDQ projects and configure

## Important: Destroying Environment 
Recommended to detach the public IPs attached on the servers to be able to destroy the environment with no isses. 

