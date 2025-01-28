packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "centos" {
  ami_name      = "tr-proving-ground"
  source_ami    = "ami-03619007682d0cd71"
  instance_type = "t2.micro"
  region        = "us-east-2"
  ssh_username = "centos"
  launch_block_device_mappings {
    device_name = "/dev/sdi"
    volume_size = "50"
    volume_type = "gp3"
    iops = 3000
    throughput = 125
    delete_on_termination = false
   }
}

build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.centos"
  ]
  
  provisioner "file" {
     source = "./files/index.html"
     destination = "/tmp/index.html"
  }

 provisioner "file" {
     source = "./files/CentOSBase.repo"
     destination = "/tmp/CentOSBase.repo"
  }

 provisioner "file" {
     source = "./files/webserver_ip.sh"
     destination = "/tmp/webserver_ip.sh"
  }

 provisioner "file" {
     source = "./files/get_public_ip.py"
     destination = "/tmp/get_public_ip.py"
  }

 provisioner "shell" {
     script = "./scripts/tr-proving-web-server.sh"
  }

}
