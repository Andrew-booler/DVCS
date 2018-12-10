# DVCS Testing Report for Group 1

## Testing Environment

- iOS 10.14.1 

- ruby 2.5.1p57

## Bug Report

### 1. Bug for status

Please test as following

`echo "FOO" >> foo.txt`

`echo "BAR" >> bar.txt`

`jsaw init` 

`jsaw add foo.txt`

`jsaw commit "add foo.txt"`

`jsaw status` 

`=> "Changed: foo.txt"`  # `=>` means output

`jsaw add bar.txt`

`jsaw commit "add bar.txt"`

`jsaw status`

`=> "Changed: bar.txt"`

`=> "Changed: foo.txt"`  # **ERROR**: the output should only be ` "Changed: foo.txt"` , because only `bar.txt` is changed from last commit.

## Conclusion

Group 1 does a good job!







