variable "subscriptionID" {
    type = string
    description = "Variable for our resource group"
}

variable "resourceGroupName" {
    type = string
    description = "name of resource group"
}

variable "location" {
    type = string
    description = "location of your resource group"
}

variable "securityGroup" {
    type = string
    description = "name of securityGroup"
}

variable "virtualNetwork" {
    type = string
    description = "name of virtualNetwork"
}

variable "disk_name" {
    type = string
    description = "disk name"
}

variable "vm_name" {
    type = string
    description = "vm name"
}

variable "image_publisher" {
    type = string
    description = "name of vim publisher"
}

variable "image_offer" {
    type = string
    description = "name of vim offer"
}

variable "image_sku" {
    type = string
    description = "name of vim sku"
}

variable "image_version" {
    type = string
    description = "name of vim version"
}

variable "vm_admin" {
    type = string
    description = "name of vm admin"
}

variable "vm_pass" {
    type = string
    description = "vm password"
}