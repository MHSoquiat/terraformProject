module "vpc" {
  source = "./modules/network"
}

module "bastion-host" {
  source    = "./modules/bastion-host"
  subnet_id = module.vpc.all_subnet_ids["pub_sub-1"]
  vpc_id    = module.vpc.vpc_id
}

module "frontend" {
  source     = "./modules/frontend"
  vpc_id     = module.vpc.vpc_id
  balb_dns   = module.backend.balb_dns
  bastion_sg = module.bastion-host.bastion_sg
  subnet_id = {
    alb = [
      lookup(module.vpc.all_subnet_ids, "pub_sub-1"),
      lookup(module.vpc.all_subnet_ids, "pub_sub-2"),
    ],
    asg = [
      lookup(module.vpc.all_subnet_ids, "priv_sub-1"),
      lookup(module.vpc.all_subnet_ids, "priv_sub-3"),
    ]
  }
}

module "backend" {
  source     = "./modules/backend"
  vpc_id     = module.vpc.vpc_id
  fasg_sg    = module.frontend.fasg_sg
  bastion_sg = module.bastion-host.bastion_sg
  subnet_id = [
    lookup(module.vpc.all_subnet_ids, "priv_sub-2"),
    lookup(module.vpc.all_subnet_ids, "priv_sub-4"),
  ]
}

terraform {
  backend "s3" {}
}