variable "DOCKER_USERNAME" {default = ""}
variable "DOCKER_PASSWORD" {default = ""}

locals{
  app_name = "example_app"
  app_port = 8080
  instace_type = "t2.micro"
  device_name = "/dev/sdf"
  vol_size = 20
}