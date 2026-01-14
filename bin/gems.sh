#!/bin/zsh
eval "$(rbenv init - zsh)"
cd app
#rbenv exec bundle lock --add-platform x86_64-linux
#rbenv exec bundle config unset --local deployment
#rbenv exec bundle config set --local path 'vendor/bundle'
#rbenv exec bundle config set --local without development
#rbenv exec bundle install

dir=`pwd`
docker run --platform=linux/x86_64 \
  -v "$dir":"$dir" \
  -w "$dir" \
  public.ecr.aws/sam/build-ruby3.4 \
  bash -c "bundle lock --add-platform x86_64-linux && bundle config unset --local deployment && bundle config set --local path 'vendor/bundle' && bundle config set --local without 'development test' && bundle install"

echo 'Installing ALL gems including development'
rbenv exec bundle clean
rbenv exec bundle config unset --local path
rbenv exec bundle config unset --local without
rbenv exec bundle install
cd ..
