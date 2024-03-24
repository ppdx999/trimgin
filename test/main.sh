#!/bin/bash

set -e

root_dir=$(dirname $(cd $(dirname $0) && pwd))
test_dir=$root_dir/test
cmd=$root_dir/target/debug/trimgin

result=$(mktemp)
trap 'rm -f $result' EXIT

# Build the project
$(cd $root_dir && cargo build > /dev/null 2>&1)

test_fail() {
  exit 1
}

assert_result() {
  if [ "$(cat $1)" != "$(cat $result)" ]; then
    printf "\033[1;31mTest $1 failed\033[0m\n"
    echo
    printf "\033[1;31mExpected stdout: \n$(cat $1)\033[0m\n"
    echo
    printf "\033[1;31mActual stdout  : \n$(cat $result) \033[0m\n"
    exit 1
  fi
}

run_test() {
  echo "Running test $1"

  #
  # Arrange & Act
  # 
  cat $1/in.txt | $cmd > $result

  #
  # Assert
  #
  assert_result $1/out.txt
}

# Test filtering behavior
run_test $test_dir/empty
run_test $test_dir/un_trimmable
run_test $test_dir/leading_blank
run_test $test_dir/trailing_blank
run_test $test_dir/leading_and_trailing_blank
run_test $test_dir/leading_empty_lines
run_test $test_dir/trailing_empty_lines
run_test $test_dir/leading_and_trailing_empty_lines

echo "Testing help message"
$cmd -h > $result
assert_result $test_dir/help.txt

echo "Testing read from file"
$cmd $test_dir/example.txt > $result
assert_result $test_dir/example.txt

echo "Testing reading from stdin with '-'"
cat $test_dir/example.txt | $cmd - > $result

printf "\033[1;32mAll tests passed\033[0m\n"
