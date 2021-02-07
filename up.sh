#!/bin/bash

set -e

# EDIT THIS:
#------------------------------------------------------------------------------#
NUM_WORKER_NODES=3
WORKER_NODES_INSTANCE_TYPE=t2.medium
STACK_NAME_NETWORK=eks-network
STACK_NAME_RDS=eks-rds
STACK_NAME=eks-cluster
KEY_PAIR_NAME=jenkins-eks-key
#------------------------------------------------------------------------------#

# Output colours
COL='\033[1;34m'
NOC='\033[0m'

echo -e  "$COL> Deploying CloudFormation stack...$NOC"
aws cloudformation deploy \
  "$@" \
  --template-file network.yml \
  --capabilities CAPABILITY_IAM \
  --stack-name "$STACK_NAME_NETWORK" \
  --region us-east-1

aws cloudformation deploy \
  "$@" \
  --template-file rds.yml \
  --capabilities CAPABILITY_IAM \
  --stack-name "$STACK_NAME_RDS" \
  --region us-east-1

aws cloudformation deploy \
  "$@" \
  --template-file eks.yml \
  --capabilities CAPABILITY_IAM \
  --stack-name "$STACK_NAME" \
  --parameter-overrides \
      KeyPairName="$KEY_PAIR_NAME" \
      NumWorkerNodes="$NUM_WORKER_NODES" \
      WorkerNodesInstanceType="$WORKER_NODES_INSTANCE_TYPE" \
  --region us-east-1

echo -e "\n$COL> Updating kubeconfig file...$NOC"
aws eks update-kubeconfig "$@" --name "$STACK_NAME" --region us-east-1 --kubeconfig ~/.kube/config

echo -e "\n$COL> Configuring worker nodes (to join the cluster)...$NOC"
# Get worker nodes role ARN from CloudFormation stack output
arn=$(aws cloudformation describe-stacks \
  "$@" \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='WorkerNodesRoleArn'].OutputValue" \
  --output text --region us-east-1)
  echo $arn


cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: $arn
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF

echo -e "\n$COL> Almost done! Cluster will be ready when all nodes have a 'Ready' status."
echo -e "> Check it with: kubectl get nodes --watch$NOC"
kubectl get svc
kubectl get nodes