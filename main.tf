
#  Local Variables 

locals {
  mongodb_atlas_org_id  = "6043ba893029ae62292101ea"
  mongodb_atlas_database_username = "workableAdmin"
  mongodb_atlas_database_user_password = "workable123"
  mongodb_atlas_whitelistip = "46.103.81.123"
}

# Configure the MongoDB Atlas Provider


terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "0.8.2"
    }
  }
}

provider "mongodbatlas" {
  public_key = var.mongodb_atlas_api_pub_key
  private_key  = var.mongodb_atlas_api_pri_key
}


#Configure github provider


provider "github" {
  token        = var.github_token
  organization = "PanagiotisMouratidis"
}

resource "github_repository" "terraform-repo" {
  name        = "terraform-repo"
  description = "Repository for use with Terraform"
}


# Create a Project

resource "mongodbatlas_project" "my_project" {
  name   = "workableTask"
  org_id = local.mongodb_atlas_org_id
}


# Create a Shared Tier Cluster

resource "mongodbatlas_cluster" "my_cluster" {
  project_id              = mongodbatlas_project.my_project.id
  name                    = "workableCluster"

  provider_name = "TENANT"

  backing_provider_name = "GCP"

  provider_region_name = "WESTERN_EUROPE"

  provider_instance_size_name = "M2"

  disk_size_gb                = "2"

  mongo_db_major_version = "4.4"
  auto_scaling_disk_gb_enabled = "false"
}


# Create an Atlas Admin Database User

resource "mongodbatlas_database_user" "my_user" {
  username           = local.mongodb_atlas_database_username
  password           = local.mongodb_atlas_database_user_password
  project_id         = mongodbatlas_project.my_project.id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}


# Create an IP Whitelist


resource "mongodbatlas_project_ip_whitelist" "my_ipaddress" {
      project_id = mongodbatlas_project.my_project.id
      ip_address = local.mongodb_atlas_whitelistip
      comment    = "My IP Address"
}

# Use terraform output to display connection strings.
output "connection_strings" {
value = [mongodbatlas_cluster.my_cluster.connection_strings]
}
