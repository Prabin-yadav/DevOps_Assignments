terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "local" {}

resource "local_file" "my_example_file" {
  filename = "example.txt"
  content  = "This content has been updated by Terraform!"
}