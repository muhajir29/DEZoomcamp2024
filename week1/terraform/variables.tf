variable "credentials" {
    description = "My Credentials"
    default = "./training-de.json"
}

variable "project" {
  description = "My Project Name"
  default = "orag-big-data"
}

variable "region" {
  description = "Region"
  default = "us-central1"
}

variable "location" {
    description = "Project Location"
    default = "US"
  
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  #Update the below to what you want your dataset to be called
  default     = "training_de_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default     = "training_de_bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}

