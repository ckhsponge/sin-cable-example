# sin-cable-example
Use AWS API Gateway for websockets, example with Terraform, Ruby, AnyCable

## Setup

```bash
# load gems, compile as linux for lambda
bin/gems.sh

cd infrastructure/main
# create backend.tf
terraform init
terraform apply
# take note of stage_invoke_url and database_host

cd ../..

cd app
export AWS_REGION=us-east-1
# use profile or aws creds
export AWS_PROFILE=YOUR-AWS-PROFILE
export DATA_BASE_HOST=YOUR-DSQL-HOST
bundle exec rake db:migrate

# copy the stage_invoke_url into src/WebSocketDemo.tsx
npm i
npm run build
npm run dev
```
