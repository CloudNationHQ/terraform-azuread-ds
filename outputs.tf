output "domain_service" {
  description = "contains all domain service configuration"
  value       = azurerm_active_directory_domain_service.this
}

output "replica_sets" {
  description = "contains all replica sets"
  value       = azurerm_active_directory_domain_service_replica_set.this
}

output "trusts" {
  description = "contains all domain trusts"
  value       = azurerm_active_directory_domain_service_trust.this
  sensitive   = true
}
