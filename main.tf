terraform {
  backend "s3" {
    bucket                      = "minio-dev"
    key                         = "terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    endpoint                    = "https://minio.mltrn.rocks"
    force_path_style            = "true"
  }
}

provider "vcd" {
  user                 = var.vcd_user
  password             = var.vcd_pass
  auth_type            = "integrated"
  org                  = var.vcd_org
  vdc                  = var.vcd_vdc
  url                  = var.vcd_url
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
}

data "template_file" "docker" {
  template = "${file("${path.module}/install-docker.sh")}"
}

resource "vcd_vapp" "create_vapp" {
  name = "minio"
}

resource "vcd_vapp_org_network" "minio_network" {
  vapp_name        = "minio"
  org_network_name = "manage-net"
  depends_on = [
    vcd_vapp.create_vapp,
  ]
}

resource "vcd_vapp_vm" "vm_with_docker" {
  vapp_name     = "minio"
  name          =  var.vm_name
  catalog_name  = "Linux"
  template_name = "CentOS-8.0.1905-x86_64-Server-Eng"
  storage_profile = "SSD"
  memory        = 8192
  cpus          = 2
  cpu_cores     = 1
  guest_properties = {
    "guest.hostname" = var.vm_name,
  }
  override_template_disk {
    bus_type         = "paravirtual"
    size_in_mb       = "300000"
    bus_number       = 0
    unit_number      = 0
    iops             = 0
    storage_profile  = "SSD"
  }
  network {
    type               = "org"
    name               = vcd_vapp_org_network.minio_network.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }
  customization {
    initscript = data.template_file.docker.rendered
  }
  depends_on = [
    vcd_vapp.create_vapp,
    vcd_vapp_org_network.minio_network,
  ]
}

data "template_file" "hosts" {
  template = "${file("templates/hosts.tpl")}"
  vars = {
    ip_addr = vcd_vapp_vm.vm_with_docker.network[0].ip
  }
}

resource "local_file" "hosts" {
  content  = data.template_file.hosts.rendered
  filename = "ansible/hosts.yaml"
}

resource "null_resource" "ansible-playbook" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ./ansible/hosts.yaml --user root ./ansible/playbook.yaml"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    vcd_vapp_vm.vm_with_docker,
  ]
}
