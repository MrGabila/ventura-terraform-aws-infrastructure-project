
## Deploy the Modules in the proper order listed below
- Network
- Infrastructure
- Database
- Storage
- Application

## Run these commands in each module to deploy the full environment.
terraform init
terrafrom validate
terraform plan  # Inspect the resources to be created
terraform apply --auto-approve

### The Network Module Output variables
- nat_lb_subnet_ids
- web_subnet_ids
- app_subnet_ids
- db_subnet_ids
- security_group_ids
### The Infrastructure Module Output variables
- bastion_public_ip
- frontend_lb_dns_name
- frontend_TG_arn
- backend_lb_dns_name
- backend_TG_arn
### The Database Module Output variables
- 
- 
- 
### The Storage Module Output variables

