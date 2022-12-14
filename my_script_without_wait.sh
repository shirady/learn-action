#!/bin/bash
set -x
kubectl get pods --v=8
retval_complete=1
retval_failed=1
while [[ $retval_complete -ne 0 ]] && [[ $retval_failed -ne 0 ]]; do
  sleep 5
  output=$(kubectl wait --for=condition=failed job/noobaa-tests-s3 --timeout=0 2>&1)
  retval_failed=$?
  output=$(kubectl wait --for=condition=complete job/noobaa-tests-s3 --timeout=0 2>&1)
  retval_complete=$?
done

kubectl logs job/noobaa-tests-s3 --tail 10000

if [ $retval_failed -eq 0 ]; then
    echo "Job failed. Please check logs."
    exit 1
fi

# source:
# https://stackoverflow.com/questions/55073453/wait-for-kubernetes-job-to-complete-on-either-failure-success-using-command-line
