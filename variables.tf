variable "resourceName" {
  description = "describes key vault related configuration"
  type = object({
  })
}

variable "naming" {
  description = "contains naming convention"
  type = object({
  })
  default = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
