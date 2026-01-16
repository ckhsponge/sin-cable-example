# sin-cable-example
Use AWS API Gateway for websockets, example with Terraform, Ruby, AnyCable

## Setup

```bash
# load gems, compile as linux for lambda
bin/gems.sh

# configure the remote server including remote database
cd infrastructure/main
# create backend.tf
terraform init
terraform apply
# take note of stage_invoke_url and database_host
# copy them into your .env
# also add your AWS_PROFILE or AWS keys into .env

cd ../..

cd app
bundle exec rake db:migrate

# copy the stage_invoke_url into src/WebSocketDemo.tsx
npm i
npm run build
npm run dev

# start the local server with:
bin/start.sh

# the locally hosted web UI can connect to the remote or local server
open http://localhost:5174/
```
