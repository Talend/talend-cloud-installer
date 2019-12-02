## Update in @puppet-activemq

### PR
  - fix(DEVOPS-8042): Start the service as non-root #18
  - feat(DEVOPS-7796): Limit message size #19

### Testing
```
export PACKAGECLOUD_MASTER_TOKEN=...
./scripts/local_dev_tests.sh
```

### Build
Get a new "tag release" https://ci-cloud.datapwn.com/job/puppet-activemq_master_master/
=> 0.4.7

## Update in @talend-cloud-installer
using the DEVOPS branch (set in ../Puppetfile)

### PR
  - Version bump for ActiveMQ #298  <== tag from the build
  - feat(DEVOPS-8075): limit HTTP messages size by nginx #299
  - feat(DEVOPS-7961): define max conn to 3000 on hiera puppet role #300

### Testing
```
export PACKAGECLOUD_MASTER_TOKEN=...
./scripts/local_dev_tests.sh -t role-activemq-centos-77
```

### Manual build
Get a new "tag release" https://ci-cloud.datapwn.com/job/talend-cloud-installer_master_master/
=> 0.1.0.621

## Build the ActiveMQ AMI

Automatic ?

### Build
https://ci-cloud.datapwn.com/view/Talend-cloud/job/talend-cloud-installer-ami-activemq/

## Declare manifest in @talend-cloud-build

### PR
  - TICO-3402: activemq reconfigure with nginx #568  <== reference the AMIs

## Updates in @talend-cloud-installer-hiera (1env = 1branch)

### PR
  - feat(DEVOPS-7961): activemq nginx in integration #869
  - feat(DEVOPS-7961): activemq nginx in qa #870
  - feat(DEVOPS-7961): activemq nginx in dw #871
  - TICO-3402: activemq nginx in staging20 #876
  - TICO-3402: activemq nginx in data-migration-testing #880
  - TICO-3402: activemq nginx in production20-ap #877
  - TICO-3402: activemq nginx in production20-eu #878
  - TICO-3402: activemq nginx in production20-us #879

### Multibranch edit
.idea/NOTES.md

### Manual build
  - https://ci-cloud.datapwn.com/job/talend-cloud-installer-hiera_branch_talend-cloud-integration/
  - https://ci-cloud.datapwn.com/job/talend-cloud-installer-hiera_branch_talend-cloud-qa/
  - https://ci-cloud.datapwn.com/job/talend-cloud-installer-hiera_branch_daily-web-datapwn/
  - https://ci-cloud.datapwn.com/job/talend-cloud-installer-hiera_branch_staging20/
  - https://ci-cloud.datapwn.com/job/talend-cloud-installer-hiera_branch_data-migration-testing/
  - https://ci-cloud.datapwn.com/job/talend-cloud-installer-hiera_branch_production20/

## Update CloudFormation stack with @talend-cloud-provisioner (into maintenance branch)

```
TICO-XXXX-talend-cloud-integration  -> origin/talend-cloud-integration
TICO-XXXX-daily-web-datapwn         -> origin/daily-web-datapwn
TICO-XXXX-talend-cloud-qa           -> origin/talend-cloud-qa
TICO-XXXX-data-migration-testing    -> origin/data-migration-testing
TICO-XXXX-staging                   -> origin/staging20
TICO-XXXX-production20-ap           -> origin/production20
TICO-XXXX-production20-eu           -> origin/production20
TICO-XXXX-production20-us           -> origin/production20
```

### PR
  - feat(DEVOPS-8075): Define another ec2 ingress port for Nginx #1476
  - TICO-3402 activemq nginx #1478

### Cherry pick
```
cd ~/dev/Talend/talend-cloud-provisioner
git checkout maintenance/R1911
git fetch origin
git pull
git checkout -b TICO-3402_activemq-nginx
git cherry-pick a6082f2abe2c2d224398556b5b3e3f48a121bd2f
git push --set-upstream origin TICO-3402_activemq-nginx
```

### Deploy
```
./tools/ami-stack-update.py --region us-east-1 -f "ActiveMq" -a "ami-0f215e7e090ddba69" -e "0" -o "A,C,B" "talend-cloud-qa"
```

## Sync AMI to all regions with @tipaas-ops

### PR
  - TICO-3402: Update ActiveMQ AMI #690

### Deploy
Deploy is AUTOMATIC at http://jenkins-ops.talend.lan:8080/job/ami-copy/

### Get image IDs
```
export AWS_PROFILE=okta
image_name="talend-tic-activemq-0.1-1573034802-hvm"
for region in us-east-1 eu-central-1 ap-northeast-1 us-west-2 eu-west-1 ap-southeast-1; do
   image_id=$(aws ec2 describe-images --region ${region} --filters "Name=name,Values=${image_name}" --query 'Images[0].ImageId');
   echo "${region}: ${image_id}"; done
```
