Ventura PHP Mailing deployment with multi-tier architecture on AWS. It uses Amazon EC2 service for Webservers and Appservers, And RDS service for the Mysql database.

### Prerequisites:
* Terraform installed
* AWS Account and AWS cli installed

### Note

* This cluster based on the current configuration will be created in the us-east-1 region 
* The deployment takes over 15 minutes

### Resources Created
* VPC and all networking components 
* frontend and backend load balancers
* Webserver and Appservers Autoscaling groups for the EC2
* RDS Mysql Database

## Deploy the Modules in the proper order listed below
- Network
- Infrastructure
- Database
- Storage
- Application

## Change directory to each module and Run these commands to deploy the full environment.
```bash
terraform init
terrafrom validate
terraform plan  # Inspect the resources to be created
terraform apply --auto-approve
```
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

