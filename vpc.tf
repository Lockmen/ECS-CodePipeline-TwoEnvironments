module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "demo-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 10), cidrsubnet(var.vpc_cidr, 8, 11)]

  enable_nat_gateway = false
  enable_vpn_gateway = false
}

module "fck_nat" {
  source  = "RaJiska/fck-nat/aws"
  version = "1.4.0"

  name       = "${module.vpc.name}-fck-nat"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnets[0]
  ha_mode    = false
  depends_on = [module.vpc]

  update_route_tables = true
  route_tables_ids = {
    for idx, rtb_id in module.vpc.private_route_table_ids :
    "private-${idx + 1}" => rtb_id
  }
}

