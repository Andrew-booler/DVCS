# DVCS JSAW Beta Testing Report


## Overview 

After completing an initial version our JSAW DVCS system, we did a small release to a few users. The results of these testing bug reports can be found in the `BugReports` folder. In response to these reports we have modified our system to address several bugs and add more functionality.

## Bug Report Summary

After going through four bug reports, we distilled our bugs into the list below. Each bug is associated with a particular command.

* `status`
	* when add a file, it shows deleted
	* status is unchanged before and after the commit
	* status doesn't show files not added
	* status should not show files which have been committed
* `heads` 
	* crashes when using before any commits
* `commit`
	* crashes when commit a file in a directory
	* commit needs to show the message
	* crashes with non existent file
* `init`
	* doesn't check if already repo exist in folder 
* `clone` 
	* copies .jsaw folder but does not perform a checkout
	* clone just does not work in some cases since no files are copied over 
* `checkout`
	* fails
* `add`
	* does not indicate if file has already been added, breaks if adding a non existent file
* `remove`
	* files are not actually removed, files which are previously added still show up in the commit
	* does not throw an error with a non existent file 
* `log`
	* no commit message
* `diff` 
	* not working  
* `merge`
	* not working

## Bug Resolutions

Since many of our bugs seemed to be larger issues, we broke down our resolution process by command.

### status

This command simply did not behave correctly. This was a huge issue during beta testing since this is a very frequently used command. Luckily, code related to `status` is mostly contained to the repository module. We were able to track down issues related to this command and improve the functionality by adjusting a few lines in the repository module.

### heads

Because this command is relatively simple we were able to adjust our implementation and a few safety checks to avoid crashes on edge case scenarios. In addition, we were able to make output usability improvements.

### commit

### init

### clone

### add

### remove

### log

### diff

### merge

## Moving Forward

All in all, our system still contains functionality bugs and usability flaws. First and foremost we aim to eliminate these known issues. Next, we hope to add the additional functionality we were unable to include. 