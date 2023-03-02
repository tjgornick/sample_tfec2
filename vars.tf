# Create input variables for deployment
# Use a .tfvars file or export env variables to populate these values

variable "aws_access_key_id" {
  type        = string
  description = "Your AWS Access Key"
}

variable "aws_secret_access_key" {
  type        = string
  description = "Your AWS Secrey Key"
}

variable "aws_region" {
  type        = string
  description = "Region you want to deploy to"
  default     = "us-west-2"

}

variable "sample_key_pair_pub" {
  type        = string
  description = "Full path to your public key from your locally created SSH key pair - default is simply an example"
  default     = "~/.ssh/sample_tfec2.pub"
}

variable "sample_ec2_provision_script" {
  type        = string
  description = "Full path to the provision.sh script file"
  default     = "files/provision.sh"
}

#variable "key_path" {}
#variable "ssh_user" {}
#variable "key_name" {}
