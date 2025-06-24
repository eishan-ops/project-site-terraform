module "release_vms" {
  source = "./modules/compute"
  
}

# import has to be in root module - will remove after its been removed
import {
  to = module.release_vms.aws_key_pair.logger
  id = "project-site-logger" # "key-0588b2a6399ba705d"  
}

