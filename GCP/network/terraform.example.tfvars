# project_id = "<corp>-<region>-<band>-<business>-uat-002"
# vpc_name = "vpc-<band><region><business>-uat-002"
# subnets = [
#   {
#     name          = "subnet-producer-<band><region><business>-uat-002"
#     region        = "asia-east2"
#     ip_cidr_range = "10.2.0.0/17"
#   }
# ]
# psc_policies = [
#   {
#     name          = "psc-memstore"
#     location      = "asia-east2"
#     service_class = "gcp-memorystore"
#     subnetworks   = ["subnet-producer-<band><region><business>-uat-002"]
#   },
#   {
#     name          = "psc-cloudsql"
#     location      = "asia-east2"
#     service_class = "google-cloud-sql"
#     subnetworks   = ["subnet-producer-<band><region><business>-uat-002"]
#   }
# ]
