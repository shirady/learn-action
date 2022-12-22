#!/bin/bash
set -x

# wait for completion as background process - capture PID
kubectl wait --for=condition=complete job/noobaa-tests-s3 & 
completion_pid=$!

# wait for failure as background process - capture PID
kubectl wait --for=condition=failed job/noobaa-tests-s3 && exit 1 &
failure_pid=$! 

kubectl logs job/noobaa-tests-s3 --tail 10000 -f

# capture exit code of the first subprocess to exit
wait -n ${completion_pid} ${failure_pid}

# store exit code in variable
exit_code=$?

kubectl logs job/noobaa-tests-s3 --tail 10000

if [ ${exit_code} -eq 0 ] 
then
  echo "Job completed"
else
  echo "Job failed with exit code ${exit_code}, exiting..."
fi

echo $exit_code

# source:
# https://stackoverflow.com/questions/55073453/wait-for-kubernetes-job-to-complete-on-either-failure-success-using-command-line
