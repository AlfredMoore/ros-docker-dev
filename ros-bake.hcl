group "default" {
  targets = ["panda-noetic"]
}

#############################################################
# These variables are passed from env.sh
variable "IMAGE_TAG" { default = "WiscHCI/panda-noetic"}
variable "USERNAME" { default = "panda" }
variable "USER_ID" { default = "1000" }
variable "GROUP_ID" { default = "1000" }
variable "NOCACHE" { default = false }
variable "SHELL" { default = "/bin/zsh" }

#############################################################

# Editable 
# These are dockerfile path and building configurations
target "panda-noetic" {
  context = "."
  dockerfile = "panda-noetic.Dockerfile"
  args = {
    USERNAME = "${USERNAME}"
    USER_ID = "${USER_ID}"
    GROUP_ID = "${GROUP_ID}"
  }
  tags = ["${IMAGE_TAG}"]
  no-cache = "${NOCACHE}"    # set false in Development, true in Deployment
  ssh = ["default"]
}

target "stretch-humble" {
  context = "."
  dockerfile = "stretch-humble.Dockerfile"
  args = {
    USERNAME = "${USERNAME}"
    USER_ID = "${USER_ID}"
    GROUP_ID = "${GROUP_ID}"
  }
  tags = ["${IMAGE_TAG}"]
  no-cache = "${NOCACHE}"    # set false in Development, true in Deployment
  ssh = ["default"]
}