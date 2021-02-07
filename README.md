# Infra stack for MediaWiki


#########################################

**Code Format**: YAML

**Tech Stack**: Cloudformation + Jenkins

##########################################

This project uses Jenkins pipeline to deploy 3 stacks:
1. EKS-NETWORK --> Deploys VPC with 2 subnets(public)
2. EKS-RDS --> Deploys a MySQL RDS along with its security group which will be our Mediawiki database
3. EKS-CLUSTER --> Deploys EKS cluster with 3 autoscaled worker nodes for High Availability

**Note: Make sure the Jenkins server has basic plugins and aws cli installed**

> Refer the below Mediawiki app repository for information on installation & configuration:
> https://github.com/shekharsanatan92/mediawiki-eks-proj-app.git
