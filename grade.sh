#!/bin/bash
cd /code

function grade() {
  submissions=($(ls -d */))
  solution=$(cat .spec/out.txt)

  echo "Run command: $RUN_COMMAND"
  echo "SOLUTION:"
  echo "$solution"

  for submission in ${submissions[@]}; do
    echo ""
    echo "Grading $submission..."
    cd "/code/$submission"

    g++ *.cpp && COMPILED=true

    TIMING=$(time ($RUN_COMMAND >out.txt || echo "<COMPILE ERROR>" >out.txt) 2>&1)

    # diff outputs, ignore lineend whitespace
    DIFF=$(diff -b out.txt <(cat ../.spec/out.txt))

    echo Expected: >report.txt
    cat ../.spec/out.txt >>report.txt
    echo $'\nReceived:' >>report.txt
    cat out.txt >>report.txt

    echo $'\nDiff:' >>report.txt
    echo "$DIFF" >>report.txt

    echo $'\nTiming:' >>report.txt
    echo "$TIMING" >>report.txt
  done

  echo $'\nWrote reports to $submission/report.txt'
}

grade
