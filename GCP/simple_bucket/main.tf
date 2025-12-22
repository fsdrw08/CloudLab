resource "random_uuid" "uuid" {
}

resource "google_storage_bucket" "default" {
  name          = "terraform-tfstate-${split("-", random_uuid.uuid.id)[0]}"
  project       = var.project_id
  force_destroy = false
  location      = "ASIA-EAST2"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age                        = 0
      days_since_custom_time     = 0
      days_since_noncurrent_time = 0
      matches_prefix             = []
      matches_storage_class      = []
      matches_suffix             = []
      num_newer_versions         = 1
      with_state                 = "ARCHIVED"
    }
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age                        = 0
      days_since_custom_time     = 0
      days_since_noncurrent_time = 1
      matches_prefix             = []
      matches_storage_class      = []
      matches_suffix             = []
      num_newer_versions         = 0
      with_state                 = "ANY"
    }
  }

  timeouts {}

}