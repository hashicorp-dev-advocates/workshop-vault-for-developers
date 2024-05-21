module "hcp" {
  source         = "joatmon08/hcp/aws"
  version        = "5.0.2"
  hvn_cidr_block = var.hcp_cidr_block
  hvn_name       = var.name
  hvn_region     = var.region

  hcp_vault_name            = var.name
  hcp_vault_public_endpoint = true
}