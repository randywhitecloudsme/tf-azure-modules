module "nat_gateway_basic" {
  source = "../.."

  name                = "natgw-example-basic"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_associations = var.subnet_associations

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
