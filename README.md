Project Proving Ground

Description:
This project will be ssing  AWS Cloud, HashiCorp Packer, HashiCorp Terraform along with python and shell scripts to build out a set of web servers with varying configurations using the CentOs7 operating system

Dependencies:
This work was done from an aws cloud environment, so the tools are configured to make aws api calls.
The packer tool is using a CentOs7 community image that is currently available fron region us-east-2, as long as the image is available the image should build accordingly.

Installing:
On the linux server you will be working from you will need to have HashiCorp packer and HashiCorp terraform.  If they are not installed you will need to install them, you can type in the word terraform to check for terraform and /usr/bin/packer to check for packer, if no response proceed to install.

Check if available from yum repository

  	   #yum list | grep packer
       #yum list | grep terraform
If so you can install

    ex.
       #yum install -y terraform.x86_64
       #yum  install -y packer.x86_64
If terraform or packer are not showing, I have included a HashiCorp repo that can be used to obtain the packages, the repo is a CentOS8 repo buu it will work on CentOS7.

This project can be cloned to the directory you want to work from

        #git clone https://github.com/tee-roberts/proving_ground.git
        
If git is not installed you will nees to install
        #yum install -y git.x86_64

Once proving_ground repository is downloaded, you can copy over the HashiCorp repo.

      #cp ./proving_ground/packer/files/hashicorp.repo /etc/yum.repos.d/

You should now be able to do the yum install

To run packer and terraform you will need to have your AWS credentials configured.

      #cd ./proving_ground/packer/
      #/usr/bin/packer init .
      #/usr/bin/packer build aws-centos7-proving.pkr.hcl

In AWS console under Images-->AMIs, you should see an image named tr-proving-ground  

This image will be used by terraform to build the web servers.

      #cd ./proving_ground/terraform

Before running terraform there are some variables you will need to update to match your environment
There are 2 variable files proving.tfvars and proving_variables.tf you will need to update the following
                     
key_name
image_id

A tag was added to the VPC- Name:Proving_Ground

Terraform can now be run:

   #cd ./proving_ground/terraform
   #terraform init
   #terraform
   #terraform plan fmt
   #terraform apply -auto-approve

Expected Results:
You should be able to access web server1 web site by using the public address

     http://web_server_public_address
     
There will be an s3 bucket proving_web_server_1

There will be a file in the s3 bucket containing webserver1 public ip address: public_ip.txt

There will be a daily cron job on webserver2 to copy down the public ip address of webserver1 to the /data directory

The expected security groups, launch template and target groups should also exists

To remove the current build, first delete any files saved to s3 then run

    #terraform destroy -auto-approve


