variable subscription_id {
    
}
variable client_id {
    
}
variable client_secret {

}
variable tenant_id {
    
}


variable "location" {
    description = "The location where resources are created"
    default     = "East US"
    
}
variable "resource_group_name" {
    description = "The name of the resource group in which the resources are created"
    default     = "DeployingWebserverInAzure"
}

variable "value" {
    description = "Number of VM instances"
    default     = "2"
}


variable "tags" {
    type        = map(string)
    default     = {
        author  = "Geetika Jindal"
    }

}

variable  "prefix"{
    default    = "DeployingWebserverInAzure"
}


