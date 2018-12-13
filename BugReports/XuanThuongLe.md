# Bug Report

1. ## Setup
* System: MacOS 10.12.6
* Project: JSAW
* Language: Ruby 2.5.0
* Tester: Luba Le Xuan
* Date and time: 3.41 pm 12/04/18

2. ## Test Method
Running integration and unit tests provided by the group. Running self made end to end tests.

3. ## Bug List

### Integration Tests
```
ruby ../test/integration/add.rb 
```
PASS
```
ruby ../test/integration/commit.rb 
```
PASS
```
ruby ../test/integration/init.rb 
```
PASS
```
ruby ../test/integration/log.rb 
```
PASS
```
ruby ../test/integration/remove.rb 
```
PASS

### Unit tests
```
ruby ../test/module/changelog.rb 
```
FAILURE
```
ruby ../test/module/diff.rb 
```
PASS


### End to end tests

#### Test 1
```
mkdir r1
cd r1
./jsaw init
```
PASS
```
echo "loop is" > test1.txt
../jsaw add test1.txt
```
PASS
```
../jsaw status
```
PASS
*Output: "Changed: test1.txt"*
```
../jsaw commit test1.txt
```
PASS/FAIL
*Output: no commit message*
```
../jsaw checkout 0
```
FAILURE
*Error: JSAW/src/revlog.rb:67:in 'base': no implicit conversion from nil to integer (TypeError)*
```
echo "loop is" > test1.txt
 ../jsaw add test1.txt
 ```
PASS
```
 ../jsaw commit "add test1 again"
 ```
 PASS/FAIL
 *Output: no commit message*
 ```
 ../jsaw status
 ```
 PASS
 *Output: "Changed: test1.txt"*
 ```
 ../jsaw cat 1 test1.txt
 ```
 FAILURE
 *Output: "the file does not exist in given revision"*
 ```
 ../jsaw cat 0 test1.txt
 ```
FAILURE
*Output: "the file does not exist in given revision"*
 ```
../jsaw diff 0 1 test.txt
```
FAILURE
*Error: No output*
```
../jsaw remove test1.txt
```
PASS
```
../jsaw commit "Remove test1"
```
PASS/FAIL
*Output: no output message*
```
../jsaw add test1.txt
```
PASS
```
./jsaw commit "add test1 back again"
```
PASS
```
../jsaw log
```
PASS/FAIL
*Output: no commit message*


#### Test 2
```
mkdir r1
cd r1
../jsaw init
```
PASS
```
echo loop > test1.txt
../jsaw add test1.txt
```
PASS
```
../jsaw commit "add test1"
```
PASS/FAIL
*Output: no commit message*
```
mkdir ../r2
cd ../r2
../jsaw clone ./r1
```
PASS
*Output: "no repository in given directory"*
```
../jsaw clone ../r1
```
FAILURE
*Error: ls shows no files in the current directory*
```
../jsaw log
```
PASS/FAIL
*Output: no output, however shows correct revision*
```
echo "loop is bad" > test1.txt
../jsaw commit "add test1 in r2"
```
PASS/FAIL
*Output: no commit message*
```
cd ../r1
echo "loop" > test1.txt
../jsaw add test1.txt
```
PASS
```
../jsaw commit "add test1 in r1 again"
```
PASS/FAIL
*Output: no commit message*
```
../jsaw merge ../r2
```
FAILURE
*Error:JSAW/src/repository.rb:160:in 'accumulate': wrong number of arguments (given 0, expected 1) (ArgumentError)*
```
../jsaw pull ../r2
```
FAILURE
*Error: did not change test1.txt after commit*
```
../jsaw push ../r2
```
FAILURE
*Error: did not change test2.txt after commit*


### Recommendations, Suggestions, Acknowledgements
Merge, pull, push, cat, diff, clone - don't work. Commit and log - don't have commit messages, which is why I don't understand why you are collecting commit messages.
Cool that you have help command.
