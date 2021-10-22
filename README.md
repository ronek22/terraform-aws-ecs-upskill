# Terraform AWS ECS Upskill

Before first run `terraform apply` you have to create four ECR repositories in region used in terraform using AWS CLI or Console with according names
```
owner - variable owner set in terraform
Repository for CRUD APP GUNICORN
{owner}-db-app 
Repository for CRUD APP NGINX
{owner}-db-nginx
Repository for S3 APP GUNICORN
{owner}-s3-app
Repository for S# APP NGINX
{owner}-s3-nginx
```

~~And you have to push initial images to each repo with tag `latest` and optionally version tag~~

Already implemented in CI/CD Pipelines in apps repos

---

To rollback to previouse version of applications use:

`terraform apply -var s3_app_version=<version>...`