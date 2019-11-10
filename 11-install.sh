#!/usr/bin/env bash

kubectl create -f ./greetings/channel/ --validate=false
kubectl create -f ./greetings/subscription/ --validate=false
