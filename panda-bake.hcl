group "default" {
  targets = ["panda-noetic"]
}

variable "IMAGE_TAG" {
  default = "WiscHCI/panda-noetic"
}

variable "USERNAME" {
  default = "panda"
}

variable "USER_ID" {
  default = "1000"
}

variable "GROUP_ID" {
  default = "1000"
}

target "panda-noetic" {
  context = "."
  dockerfile = "panda-noetic.Dockerfile"
  args = {
    USERNAME = "${USERNAME}"
    USER_ID = "${USER_ID}"
    GROUP_ID = "${GROUP_ID}"
  }
  tags = ["${IMAGE_TAG}"]
  no-cache = false
  ssh = ["default"]
}