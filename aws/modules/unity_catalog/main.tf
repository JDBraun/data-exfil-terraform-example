
resource "databricks_metastore" "this" {
  name          = "unity-catalog-${var.resource_prefix}"
  storage_root  = "s3://${var.uc_s3}/metastore"
  force_destroy = true
}

resource "databricks_metastore_assignment" "default_metastore" {
  workspace_id         = var.databricks_workspace
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}

resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = var.uc_iam_name
  aws_iam_role {
    role_arn = var.uc_iam_arn
  }
  is_default = true
  depends_on = [
    databricks_metastore_assignment.default_metastore
  ]
}
