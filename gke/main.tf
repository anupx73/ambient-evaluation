data "google_client_config" "default" {}

module "gcp-network" {
  source                               = "terraform-google-modules/network/google"
  version                              = ">= 4.10.0"
  project_id                           = var.project_id
  network_name                         = "${var.cluster_name}-vpc"
  subnets = [
    {
      subnet_name                      = "${var.cluster_name}-subnet"
      subnet_ip                        = var.subnet_ip_range
      subnet_region                    = var.region
    },
  ]
  secondary_ranges = {
    "${var.cluster_name}-subnet" = [
      {
        range_name                     = "${var.cluster_name}-subnet-pod-ip-range"
        ip_cidr_range                  = var.pod_ip_range
      },
      {
        range_name                     = "${var.cluster_name}-subnet-service-ip-range"
        ip_cidr_range                  = var.service_ip_range
      },
    ]
  }
}

module "gke" {
  source                               = "terraform-google-modules/kubernetes-engine/google"
  project_id                           = var.project_id
  name                                 = var.cluster_name
  regional                             = false
  region                               = var.region
  zones                                = var.zones
  network                              = module.gcp-network.network_name
  subnetwork                           = module.gcp-network.subnets_names[0]
  ip_range_pods                        = "${var.cluster_name}-subnet-pod-ip-range"
  ip_range_services                    = "${var.cluster_name}-subnet-service-ip-range"
  create_service_account               = false
  service_account                      = var.service_account
  kubernetes_version                   = var.kubernetes_version
  release_channel                      = var.release_channel
  horizontal_pod_autoscaling           = true
  enable_vertical_pod_autoscaling      = true
  remove_default_node_pool             = true
  monitoring_enabled_components        = ["SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"]
  logging_enabled_components           = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  gke_backup_agent_config              = true
  gce_pd_csi_driver                    = false
  deletion_protection                  = false

  node_pools = [
    {
    name                                = "${var.cluster_name}-node-pool"
    machine_type                        = var.machine_type
    min_count                           = var.min_count
    max_count                           = var.max_count
    local_ssd_count                     = 0
    spot                                = false
    disk_size_gb                        = var.disk_size_gb
    disk_type                           = "pd-standard"
    image_type                          = "COS_CONTAINERD"
    enable_gcfs                         = false
    enable_gvnic                        = false
    auto_repair                         = true
    auto_upgrade                        = true
    service_account                     = var.service_account
    preemptible                         = false
    initial_node_count                  = var.initial_node_count
    },
  ]
}
