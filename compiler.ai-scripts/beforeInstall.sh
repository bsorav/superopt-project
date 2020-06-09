#!/bin/bash
PREFIX=$PWD/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive
apt install python3-distutils gcc g++ make-guile
rm -rf /superopt-project
