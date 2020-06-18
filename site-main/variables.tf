variable "region" {
  default = "us-east-1"
}

variable "domain" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create."
}

variable "duplicate-content-penalty-secret" {
  type = string
}

variable "deployer" {
  type = string
}

variable "acm-certificate-arn" {
  type = string
}

variable "routing_rules" {
  type    = string
  default = ""
}

variable "default-root-object" {
  type    = string
  default = "index.html"
}

variable "not-found-response-path" {
  type    = string
  default = "/404.html"
}

variable "not-found-response-code" {
  type    = string
  default = "200"
}

variable "tags" {
  type        = map(string)
  description = "Optional Tags"
  default     = {}
}

variable "trusted_signers" {
  type    = list(string)
  default = []
}

variable "forward-query-string" {
  type        = bool
  description = "Forward the query string to the origin"
  default     = false
}

variable "price_class" {
  type        = string
  description = "CloudFront price class"
  default     = "PriceClass_200"
}

variable "ipv6" {
  type        = bool
  description = "Enable IPv6 on CloudFront distribution"
  default     = false
}

variable "minimum_client_tls_protocol_version" {
  type        = string
  description = "CloudFront viewer certificate minimum protocol version"
  default     = "TLSv1"
}

variable "enable_custom_headers" {
  type        = bool
  description = "Enable custom headers via Lambda@Edge"
  default     = false
}

variable "enable_hsts" {
  type        = bool
  description = "Enable HSTS (no effect if custom headers disabled)"
  default     = false
}

variable "custom_headers_hsts_max_age" {
  type        = number
  description = "The time, in seconds, that the browser should remember that a site is only to be accessed using HTTPS (no effect if HSTS and/or custom headers disabled)"
  default     = 31536000
}

variable "enable_hsts_preload" {
  type        = bool
  description = "Enable HSTS Preload (no effect if HSTS and/or custom headers disabled)"
  default     = true
}

variable "enable_hsts_subdomains" {
  type        = bool
  description = "Enable HSTS for subdomains (no effect if HSTS and/or custom headers disabled)"
  default     = true
}

variable "custom_headers_referrer_policy" {
  type        = string
  description = "Referrer policy (no effect if custom headers disabled)"
  default     = "same-origin"
}
