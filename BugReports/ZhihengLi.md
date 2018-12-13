### JSAW Bug Report

1. ##### Init

   Whether passes: Yes

2. ##### add

   Whether passes: Yes

3. ##### log

   Whether passes: Yes

4. ##### Status

   Expected behavior: show added and removed files

   Actual behavior: 

   1. when add a file, it shows deleted
   2. status is unchanged before and after the commit
   3. status doesn't show files not added

   Steps to reproduce:

   (1)

   ```bash
   mkdir documents
   cd documents
   touch a.txt
   jsaw add documents/a.txt
   jsaw status
   "Deleted: documents/a.txt"
   ```

   (2)

   ```bash
   jsaw add a.txt
   jsaw status
   "Changed: a.txt"
   jsaw commit "add a.txt"
   jsaw status
   "Changed: a.txt"
   ```

   (3)

   ```bash
   jsaw add a.txt
   ls
   a.txt b.txt
   jsaw status
   "Changed: a.txt"
   ```

   Even if b.txt is not added, status should still show files which are not added.

   Whether passes: No

2. ##### Heads

   Expected behavior: show all heads

   Actual behavior: it crashes when using heads before any commits

   Steps to reproduce:

   ```bash
   jsaw heads
   
   Traceback (most recent call last):
   	4: from /Users/hubert/Downloads/JSAW/src/jsaw:36:in `<main>'
   	3: from /Users/hubert/Downloads/JSAW/src/repository.rb:41:in `getHead'
   	2: from /Users/hubert/Downloads/JSAW/src/repository.rb:56:in `open'
   	1: from /Users/hubert/Downloads/JSAW/src/repository.rb:56:in `open'
   	
   /Users/hubert/Downloads/JSAW/src/repository.rb:56:in `initialize': No such file or directory @ rb_sysopen - /Users/hubert/RubymineProjects/JSAW_playground/.jsaw/current (Errno::ENOENT)
   ```

   Whether passes: No

3. ##### Commit

   Expected behavior: commit all staged files. If add a directory, the repo should commit all files in the directory. The commit description should be the same in log.

   Actual behavior: 

   1. crashes when commit a file in a directory
   2. Commit description is not the given one

   Steps to reproduce:

   (1)

   ```bash
   jsaw add documents
   jsaw status
   
   "Deleted: documents"
   
   jsaw commit "add documents folder"
   
   Traceback (most recent call last):
   	4: from /Users/hubert/Downloads/JSAW/src/jsaw:58:in `<main>'
   	3: from /Users/hubert/Downloads/JSAW/src/repository.rb:100:in `commit'
   	2: from /Users/hubert/Downloads/JSAW/src/repository.rb:100:in `each'
   	1: from /Users/hubert/Downloads/JSAW/src/repository.rb:102:in `block in commit'
   /Users/hubert/Downloads/JSAW/src/repository.rb:102:in `read': Is a directory @ io_fread - documents (Errno::EISDIR)
   ```

   (2)

   ```bash
   jsaw init
   jsaw status
   jsaw add a.txt
   jsaw status
   "Changed: a.txt"
   jsaw remove a.txt
   jsaw status
   "Changed: a.txt"
   jsaw add b.txt
   jsaw commit "only add b.txt"
   jsaw status
   "Changed: a.txt"
   "Changed: b.txt"
   jsaw log
   0: -1 -1 272cd3adbbea08644c571874f504732f2ee3acb4
   manifest nodeid:12accc45b4dfe559b6a0dc5ff0ae9ee86c76c90d
   user:hubert
   changed files:
   a.txt
   b.txt
   description:
   commit
   ```

   Whether passes: No

4. ##### Clone

   Expected behavior: copy the repository to a new place and checkout to the same revision with the original one.

   Actual behavior: new repo is empty when clone a repo containing files

   Steps to reproduce:

   ```bash
   jsaw clone ../JSAW_playground
   ls
   ```

   ,where ls should outputs files committed in the other repository.

   Whether passes: No

5. ##### Checkout

   Expected behavior: all files are recover to the indicated commit

   Actual behavior: crashes when checkout to a commit

   Steps to reproduce:

   ```bash
   jsaw checkout 0
   Traceback (most recent call last):
   	1: from /Users/hubert/Downloads/JSAW/src/jsaw:42:in `<main>'
   /Users/hubert/Downloads/JSAW/src/repository.rb:152:in checkout': undefined methodcurrent=' for #Repository:0x00007fb1b28dc9d8 (NoMethodError)
   ```

   Whether pass: No

6. ##### Cat

   Expected behavior: print the file content in a specific revision.

   Actual behavior: cat shows that file doesn't exist, but it does exist.

   Steps to reproduce:

   ```bash
   jsaw cat a.txt 0
   "the file does not exist in given revision"
   ```

   Whether pass: No

7. ##### Remove

   Expected behavior: remove the files previously added.

   Actual behavior: files are not removed, files which are previously added still show up in the commit.

   Steps to reproduce:

   ```bash
   jsaw init
   jsaw status
   jsaw add a.txt
   jsaw status
   "Changed: a.txt"
   jsaw remove a.txt
   jsaw status
   "Changed: a.txt"
   jsaw add b.txt
   jsaw commit "only add b.txt"
   jsaw status
   "Changed: a.txt"
   "Changed: b.txt"
   jsaw log
   0: -1 -1 272cd3adbbea08644c571874f504732f2ee3acb4
   manifest nodeid:12accc45b4dfe559b6a0dc5ff0ae9ee86c76c90d
   user:hubert
   changed files:
   a.txt
   b.txt
   description:
   commit
   ```

   Whether pass: No

8. ##### All commands:

   Expected behavior: show message that it's a JSAW repo when it's uninitialized.

   Actual behavior: crashes when run commit in an uninitialized repo.

   Steps to reproduce:

   ```bash
   rm -rf .jsaw
   jsaw commit "haha"
   Traceback (most recent call last):
   	7: from /Users/hubert/Downloads/JSAW/src/jsaw:58:in `<main>'
   	6: from /Users/hubert/Downloads/JSAW/src/repository.rb:110:in `commit'
   	5: from /Users/hubert/Downloads/JSAW/src/manifest.rb:30:in `addmanifest'
   	4: from /Users/hubert/Downloads/JSAW/src/revlog.rb:210:in `addrevision'
   	3: from /Users/hubert/Downloads/JSAW/src/manifest.rb:11:in `open'
   	2: from /Users/hubert/Downloads/JSAW/src/repository.rb:56:in `open'
   	1: from /Users/hubert/Downloads/JSAW/src/repository.rb:56:in `open'
   /Users/hubert/Downloads/JSAW/src/repository.rb:56:in `initialize': No such file or directory @ rb_sysopen - /Users/hubert/RubymineProjects/JSAW_playground/.jsaw/00manifest.i (Errno::ENOENT)
   ```

   Whether passes: No

9. ##### Diff

   Not implemented

10. ##### Merge

    Not implemented

11. ##### Pull

    Not implemented

12. ##### Push

    Not implemented