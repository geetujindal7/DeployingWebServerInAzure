# variable subscription_id {
    
# }
# variable client_id {
    
# }
# variable client_secret {

# }
# variable tenant_id {
    
# }

#location
variable "location" {
    description = "The location where resources are created"
    default     = "East US"
    
}

#resource_group_name
variable "resource_group_name" {
    description = "The name of the resource group in which the resources are created"
    default     = "DeployingWebserverInAzure"
}

#value
variable "value" {
    description = "Number of VM instances"
    default     = "2"
}

#tag
variable "tags" {
    type        = map(string)
    default     = {
        author  = "Geetika Jindal"
    }

}

#prefix
variable  "prefix"{
    default    = "DeployingWebserverInAzure"
}


