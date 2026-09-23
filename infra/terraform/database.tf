# Banco de dados
# ---------------
# A assinatura Azure for Students não tem capacidade de MySQL Flexible
# gerenciado nas regiões permitidas pela policy (ProvisionNotSupportedForRegion).
# Por isso o MySQL roda como Container App (imagem custom em services/mysql,
# cria os 3 bancos) — definido em deploy.tf.
#
# Fora da Students, o caminho recomendado é o MySQL Flexible gerenciado; o
# histórico dessa configuração está no git.
