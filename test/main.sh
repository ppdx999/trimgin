#!/bin/bash

root_dir=$(dirname $(cd $(dirname $0) && pwd))
test_dir=$root_dir/test

result=$(mktemp)
trap 'rm -f $result' EXIT

# Build the project
$(cd $root_dir && cargo build > /dev/null 2>&1)

test_fail() {
  exit 1
}

run_test() {
  echo "Running test $1"

  #
  # Arrange & Act
  # 
  cat $1/in.txt | $root_dir/target/debug/trimgin > $result

  #
  # Assert
  #
  if [ "$(cat $1/out.txt)" != "$(cat $result)" ]; then
    printf "\033[1;31mTest $1 failed\033[0m\n"
    echo
    printf "\033[1;31mExpected stdout: \n$(cat $1/out.txt)\033[0m\n"
    echo
    printf "\033[1;31mActual stdout  : \n$(cat $result) \033[0m\n"
    exit 1
  fi
}

run_test $test_dir/empty

printf "\033[1;32mAll tests passed\033[0m\n"
