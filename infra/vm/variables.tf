variable "project" {
  type    = string
  default = "fila"
}

variable "location" {
  description = "Região permitida pela policy da Students com capacidade de VM."
  type        = string
  default     = "northcentralus"
}

variable "vm_size" {
  description = "Tamanho da VM (x86). B2as_v2 = 2 vCPU / 8 GB."
  type        = string
  default     = "Standard_B2as_v2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "allowed_ssh_cidr" {
  description = "CIDR liberado no SSH (22). Ideal restringir ao seu IP: \"SEU_IP/32\"."
  type        = string
  default     = "*"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/janailsonf-a/fila.git"
}

variable "repo_branch" {
  type    = string
  default = "main"
}

variable "tags" {
  type = map(string)
  default = {
    project = "fila"
    env     = "demo"
    owner   = "janailson"
  }
}
