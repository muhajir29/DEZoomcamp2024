terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.13.0"
    }
  }
}

provider "google" {
  project     = "orag-big-data"
  region      = "us-central1"
}

resource "google_storage_bucket" "training-de" {
  name          = "training-de-orag-big-data"
  location      = "US"
  force_destroy = true


  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}



