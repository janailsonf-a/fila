output "public_ip" {
  value = azurerm_public_ip.vm.ip_address
}

output "ssh" {
  description = "Conectar na VM."
  value       = "ssh -i ${path.module}/fila-vm.pem ${var.admin_username}@${azurerm_public_ip.vm.ip_address}"
}

output "api_url" {
  description = "API orders (pode levar ~2-3 min pós-boot pro compose subir)."
  value       = "http://${azurerm_public_ip.vm.ip_address}:8080"
}

output "rabbitmq_ui" {
  value = "http://${azurerm_public_ip.vm.ip_address}:15672"
}
