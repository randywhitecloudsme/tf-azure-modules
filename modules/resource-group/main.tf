resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "CreatedOn" = timestamp()
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreatedOn"]
    ]
  }
}

resource "azurerm_management_lock" "this" {
  count = var.lock_level != null ? 1 : 0

  name       = "${var.name}-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = var.lock_level
  notes      = "Managed by Terraform - prevents accidental deletion"
}
