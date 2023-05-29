variable "siteName" {
  type        = string
  description = "Name of the site to deploy"
  default     = "danzresume.com"
}

variable "bucketName" {
  type        = string
  description = "Name of the bucket to deploy"
  default     = "danzresume.com"
}

variable "siteAlias" {
  type        = list(any)
  description = "Aliases used for Cloudfront Distribution"
  default     = ["danzresume.com", "www.danzresume.com"]
}

variable "nsRecords" {
  type        = list(any)
  description = "NS records from the domain registrar"
  default     = []
}

variable "soaRecords" {
  type        = list(any)
  default     = []
  description = "SOA record/s of the website"
}