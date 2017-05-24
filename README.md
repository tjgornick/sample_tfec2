# sample_tfec2
## A working AWS EC2 web server in 5 minutes or less

### Intro
This project was created as a personal from-scratch exercise in infrastructure-as-code by way of [Terraform](https://www.terraform.io/) and [Amazon AWS](https://aws.amazon.com/).
I have uploaded it here as a point of reference for myself and also to help any others, like me, that learn easier from seeing a working model in action.
My intent was to take the provided [Terraform Getting Started Guide](https://www.terraform.io/intro/getting-started/install.html) to the next level.
I hope you find it useful!

## Quick-start
* Sign up for a (free) [Amazon AWS account](https://aws.amazon.com/)
  * Create an [Access Key](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
  * Create a [Key Pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)

* Install [Terraform](https://www.terraform.io/intro/getting-started/install.html)

* Clone **this** repo

* Create a [terraform.tfvars file](https://www.terraform.io/docs/configuration/variables.html) with your values:
  * `access_key = "your_access_key_provided_by_aws"`
  * `secret_key = "your_secret_key_provided_by_aws"`
  * `key_path = "path/to/where/you/saved/the/pem/provided/by/aws"`
  * `ssh_user = "ubuntu" (by default for this example)`
  * `key_name = "name_you_gave_your_key_pair_in_aws"`

* Run [terraform plan](https://www.terraform.io/docs/commands/plan.html)
  * to check that everything is in place

* Run [terraform apply](https://www.terraform.io/docs/commands/apply.html)
  * to make the magic happen

* Run [terraform refresh](https://www.terraform.io/docs/commands/refresh.html)
  * This wouldn't be necessary if not for a [bug](https://github.com/hashicorp/terraform/issues/14541) that provides the wrong information upon original completion.

* Visit the [AWS Public DNS](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#concepts-public-addresses) address that is output.
  * You can also `ssh -i path/to/your/pem ubuntu@theprovidedoutputaddress` to access your system

* Pat yourself on the back for your hard work.

### Details
This project creates an Amazon EC2 instance using an [Ubuntu](https://www.ubuntu.com/) [AMI](docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) with an attached [EBS](https://aws.amazon.com/ebs/) volume mounted as a /data drive for storage of a simple `index.html` file served by an installation of [Nginx](https://www.nginx.com/). The instance is placed into a [Security Group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) allowing only HTTP and SSH traffic through from the public.

#### Disclaimers
* The original intent of this project is strictly a proof-of-concept. If you intend to use this server further, please [Google](https://www.google.com/) web server best practices and take necessary precautions.

* Terraform implies careful use of their [provisioners](https://www.terraform.io/docs/provisioners). Indeed, the bash script I provide would be better set aside in favor of a true configuration management tool such as [Ansible](https://www.ansible.com/).

* You are using (hopefully) your real AWS account - you may incur [charges](https://aws.amazon.com/ec2/pricing/).
  * [terraform destroy](https://www.terraform.io/docs/commands/destroy.html) will tear your new web server down to avoid costs.

* If you decided to keep your new server, you may want to further restrict the ssh access in your [Security Group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) settings.
