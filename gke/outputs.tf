output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "location" {
  description = "Cluster location"
  value       = module.gke.location
}

output "region" {
  description = "Cluster region"
  value       = module.gke.region
}

output "master_kubernetes_version" {
  description = "Cluster kubernetes version"
  value       = module.gke.master_version
}
