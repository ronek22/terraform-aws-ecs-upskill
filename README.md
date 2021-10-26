# Terraform AWS ECS Upskill

1. Run `terraform init` in both directories: `management` & `applications`
2. Create ECR Repositories by running `terraform apply` in `management` directory
3. Push images manually or through pipeline (Deployment Step)
4. Then you can run `terraform apply` in `applications` directory

### Applications Repositories
* [S3 App](https://github.com/ronek22/flask-s3-presigned-url)
* [CRUD App](https://github.com/ronek22/activity-tracker)
---

To roll back to previous version of applications run in `applications` directory:

`terraform apply -var='s3_app_version=<version>' -var='db_app_version=<version>'`