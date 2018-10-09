#!/bin/bash

# script to check memory utilization and restart nexus process

free=$(free -mt | grep Total | awk '{print $4}')
## check if free memory is less or equals to  500MB
if [[ "$free" -le 500  ]]; then
  INSTANCE_COUNT=1
  INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
  REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | grep region|awk -F\" '{print $4}')
  ELB_NAME=$(aws elb describe-load-balancers --region ${REGION} --query "LoadBalancerDescriptions[?Instances[?InstanceId== '${INSTANCE_ID}' ]].[LoadBalancerName]" --output text)
  COUNT_I=$(aws elb describe-instance-health --load-balancer-name ${ELB_NAME}  --region ${REGION} --query 'InstanceStates[?State==`InService`]' --output text | wc -l) 
    if [[ "$COUNT_I" -gt "$INSTANCE_COUNT" ]]; then
      systemctl restart nexus
    fi

fi
