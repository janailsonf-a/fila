variable "project" {
  description = "Prefixo curto usado nos nomes dos recursos."
  type        = string
  default     = "fila"
}

variable "location" {
  description = "Região do Azure."
  type        = string
  default     = "brazilsouth"
}

variable "mysql_admin_user" {
  description = "Usuário administrador do MySQL Flexible Server."
  type        = string
  default     = "fila_admin"
}

variable "mysql_admin_password" {
  description = "Senha do admin do MySQL. Definir via TF_VAR_mysql_admin_password (nunca commitar)."
  type        = string
  sensitive   = true
}

variable "rabbitmq_password" {
  description = "Senha do RabbitMQ (guardada no Key Vault). Definir via TF_VAR_rabbitmq_password."
  type        = string
  sensitive   = true
}

variable "databases" {
  description = "Bancos por serviço (um por microserviço com estado)."
  type        = list(string)
  default     = ["orders", "inventory", "payment"]
}

variable "deploy_apps" {
  description = "Cria os Container Apps. Deixar false até as imagens existirem no ACR (build-push), depois true."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default = {
    project = "fila"
    env     = "dev"
    owner   = "janailson"
  }
}
