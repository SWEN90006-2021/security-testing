#!/bin/bash
PUT=$1          #ARG-1: the program under test
INPUT_MODEL=$2  #ARG-2: input model/grammar
ITERATION=$3    #ARG-3: number of fuzzing iterations
OUTDIR=$4       #ARG-4: output directory

FAULT_DETECTED=0 #Initialize the number of detected faults
rm -rf $OUTDIR > /dev/null 2>&1 #Delete current result folder, ignore error messages
mkdir -p $OUTDIR #Create a folder to keep results

for i in $(seq 1 $ITERATION)
do
  echo "Generation-based fuzzing is running at the $i iteration ..."
  #Generate fuzz data following the given input model
  peach --range $i,$i $INPUT_MODEL
  #Save fuzz data to a file for futher analysis
  cp fuzz.dat $OUTDIR/fuzz$i.dat
    
  #Execute the program under test (e.g., pngimage of LibPNG)
  $PUT fuzz.dat /dev/null 2>&1

  #Detect faults (e.g., segmentation fault)
  res=$? #get the exit code
  if [ $res -eq 139 ] #139: segmentation fault
  then
    echo "A segmentation fault has been detected!"
    #Save reproducible input for debugging and fixing
    FAULT_DETECTED=$((FAULT_DETECTED + 1))
    cp fuzz.dat $OUTDIR/fault${FAULT_DETECTED}.dat
  fi
done

echo "We are done! $FAULT_DETECTED faults have been detected!"
