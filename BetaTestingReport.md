# DVCS JSAW Beta Testing Report

## Overview 

After completing an initial version our JSAW DVCS system, we did a small release to a few users. The results of these testing bug reports can be found in the `BugReports` folder. In response to these reports we have modified our system to address several bugs and add more system functionality. 

In this document we first summarize the bug reports. Next, we concisely state our bug diagnoses' and resolutions. Last, we set goals for how to improve our system moving forward. 

## Bug Report Summary

After going through four bug reports, we distilled our bugs into the list below. Each bug is associated with a particular command.

* `status`
	* when adding a file, it some cases it shows it as deleted
	* status is unchanged before and after the commit
	* status doesn't show files not added
	* status should not show files which have been committed
* `heads` 
	* crashes when using before any commits
* `commit`
	* crashes when commiting a file in a directory
	* commit needs to use the user message
	* crashes with non-existent file
* `init`
	* doesn't check if already repo exist in folder 
* `clone` 
	* copies .jsaw folder but does not perform a checkout
	* clone just does not work in some cases since no files are copied over 
* `checkout`
	* fails
* `add`
	* does not indicate if file has already been added
	* breaks if adding a non existent file
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

This command simply did not behave correctly. This was a huge issue during beta testing since this is a very frequently used command. Luckily, code related to `status` is mostly contained to the repository module. We were able to track down issues related to this command and improve the functionality by adjusting a few lines in the repository module. Specifically we found an error with our Revlog which caused the function to break when it came down to comparing files with the same name and size. To work around this bug we added a fix to compare files by modification times. Another problem we fixed was a usability issue. We added a "staging" section which works by looking at which files are in the "to-add" file and prints them.


### heads

Because this command is relatively simple we were able to adjust our implementation and a few safety checks to avoid crashes on edge case scenarios. In addition, we were able to make output usability improvements. Specifically, after repository initialization, we create a null revision in changelog and manifest. To display all the heads, we added a list in the repository to hold all the heads and update it each time commit is called.


### commit

While we still have some outstanding known bugs with commit, we did fix the handling of commit messages to properly save user messages. Tracking this bug down was relatively easy and ended being a very small change. Making this change also solved a bug related to the log command's output.

### init

To fix the problems we had with init, we check for the existence of a .jsaw folder to see if there is a repository in the directory. If the hidden .jsaw folder exists, the initialize function will return nothing and output an error message.

### clone

Clone didn’t work because the system was always using the current working directory to initialize the repository object. This meant that when clone was called in a different directory the repository object would be nil. We have fixed this by not always using the current directory to initialize the repository object.

### add

The issues we had around add were mostly caused by missing some edge case scenarios. To resolve these issues we have added some simple checks. For example, we now check that a file really exists before adding it.

### remove

In our first iteration of the JSAW system implementation we did not correctly remove files from the staging area. It was easy to track down this error in the repository module and we have since adjusted the implementation to actually remove files from the "staging" area as a user would expect.

### log

Our bug with log was one our simplest. Since we did not properly handle commit messages, the messages did not display in our log outputs. After properly handling commit messages, a small change, we now can properly display full, correct log outputs.

## Moving Forward

All in all, our system still contains functionality bugs and usability flaws. First and foremost we aim to eliminate these known issues. Next, we hope to add the additional functionality we have been unable to include. 