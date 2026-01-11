terraform {
  cloud {
    organization = "voulezvous"
    workspaces { 
      name = "vvtv-cloudflare-prod" 
    }
  }
  required_version = ">= 1.6.0"
}
