#!/bin/bash
PUT=$1          #ARG-1: the program under test
ITERATION=$2    #ARG-2: number of fuzzing iterations
OUTDIR=$3       #ARG-3: output directory

FAULT_DETECTED=0 #Initialize the number of detected faults
rm -rf $OUTDIR > /dev/null 2>&1 #Delete current result folder, ignore error messages
mkdir -p $OUTDIR #Create a folder to keep results

for i in $(seq 1 $ITERATION)
do
  echo "Random fuzzing is running at the $i iteration ..."
  #Generate fuzz data: a random string of length i
  fuzz=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c$i)
  echo "+ Fuzz data: $fuzz"
  
  #Execute the program under test
  echo $fuzz | $PUT > /dev/null 2>&1

  #Detect faults (e.g., segmentation fault)
  res=$? #get the exit code
  if [ $res -eq 139 ] #139: segmentation fault
  then
    echo "A segmentation fault has been detected!"
    #Save reproducible input for debugging and fixing
    FAULT_DETECTED=$((FAULT_DETECTED + 1))
    echo $fuzz > $OUTDIR/fault${FAULT_DETECTED}.txt
  fi
done

echo "We are done! $FAULT_DETECTED faults have been detected!"
