variable "bucket_name" {
  description = "unique identifier for the s3 bucket, must be lowercase"
  type = string
  default = "terra-"
}

variable "versioning" {
  description = "list of bucket version states, options are Enabled(2), Suspended(1), or Disabled(0)"
  type = list(string)
  default = ["Disabled", "Suspended", "Enabled"]
}

variable "version_state" {
  description = "select version state. must be a number, Options are 2(Enabled), 1(Suspended), or 0(Disabled)"
  type = number
  default = 0
}

variable "block_public_access" {
  description = "block public access of bucket, must be a bool, default=true"
  type = bool
  default = true
}