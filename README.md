# JSAW Distributed Version Control System

This project is a very simple version of a distributed version control system. This project was developed as part of a software development course at the University of Rochester. Since the primary focus of this project was to practice developing with a team, we did not spend significant time attempting to improve existing algorithms. Furthermore, we used the original version of mercurial as a significant guide for our work.

## Getting Started

To get started with the JSAW system please clone the project from Github with the following command:

`git clone https://github.com/sbudker/DVCS.git`

Next, please install the bundler gem by typing in the following command:

`gem install bundler`

Then install the project gems by typing:

`bundle install`

Now you should be able to run the JSAW system!

## Project Structure

```
/DVCS
	/.git
	/images
		LogRelationshipDiagram.png
		ModuleUseDiagram.png
	/src
		changelog.rb
		diff.rb
		filelog.rb
		jsaw
		manifest.rb
		repository.rb
		revlog.rb
	/test
		/integration
			add.rb
			commit.rb
			init.rb
			log.rb
			remove.rb
		/module
			changelog.rb
			diff.rb
			filelog.rb
			jsaw.rb
			manifest.rb
			repository.rb
			revlog.rb
	.gitignore
	Gemfile
	README.md
	Gemfile.lock
```

- `/images` contains images for documentation
- `/src` all source code for JSAW tool to operate
- `/test` all project tests to ensure JSAW quality and correctness
-  `Gemfile` specifies project dependencies 
-  `README.md` written project descriptiomn
 
## Usage

To use this system please navigate into the `src` folder. From here you will see files required to run the JSAW tool. Please ignore these files. 

The simplest way to use our system is to create and track your files in this folder. Below is a simple usage example:

```
# create test file
touch test.txt
echo "hello world!" >> test.txt

./jsaw init # initialize a new JSAW repository
./jsaw add test.txt # add test.txt 
./jsaw commit "adding test.txt!" # commit the staged changes
```

After developing with our system and obtaining a more complex revision history you may find `./jsaw log` to be useful.

For a comprehensive list of valid JSAW commands use `./jsaw help`

## Tests

### Testing strategy

To ensure the quality of this project we implemented a suite of unit tests and integration tests. 

#### Integration Tests

The integration tests aim to cover the integration of project modules. These tests vary significantly in how many modules are needed for success. Some of these tests require almost the entire system and act as effective end to end tests. Developing these integration tests was often tricky since it required setting up relatively complex environments.

#### Module Unit Tests

This set of tests found in `test/module` covers functionality and complex logic contained in individual modules. These test are used to ensure our modules produces the correct outputs. These were extremely useful prior to integrating modules because we could ensure methods were behaving as expected.

### Running the Tests

There are two recommended ways to run the tests. The first is from the `src` folder and the second is from the `DVCS` root. 

**Method One: within `src`**

```
# run the add integration test
ruby ../test/integration/add.rb 

# run the diff unit tests
ruby ../test/module/diff.rb 
```

**Method Two: within project root**

```
# run the add integration test
ruby test/integration/add.rb 

# run the diff unit tests
ruby test/module/diff.rb 
```


## Built With

- [bundler](https://bundler.io/) - Gem dependency management 
- [diff-lcs](https://github.com/halostatue/diff-lcs) - Diff computation gem
- [minitest](https://github.com/seattlerb/minitest) - Unit and integration tests

## Development Experience

To create this project we had a team of four. Unlike working a job, we faced many different constraints. Our most pressing constraint was time. Because of other work and obligations we always found ourselves struggling to have enough time. In order to try to alleviate this problem we set up several weekly work times to commit ourselves to deadlines and follow our management plan.

Unfortunately, as is often the case when developing, the complexity of our project inhibited us from meeting many of our goals. This pushed back much our testing work and ended up seriously effecting our final product's quality, correctness, robustness, and usability. To make the best product under our constraints and problems we encountered we needed to make some serious choices about key functionality. This led to some tough sacrifices like completing redesigning our revlog and scrapping some non essential JSAW commands. While these tradeoffs were hard we got really valuable experience about how and why to make certain choices when working on complex project with a team.

## Future Improvements

Since our JSAW system has known problems, our first priority would be to ensure we resolve these issues. Next, we would like to implement all the commands we aimed to complete in our initial project design stage. While the plan was ambitious at the time, we found everything included to be essential for meeting the project requirements and making a quality, usable version control system. Last, something we did not explicitly state in our initial project goals is to make our system more robust to increase usability. Specifically, in testing we found a simple way to make our JSAW tool accessible from anywhere in the file system like git or mercurial. With this small change our tool would improve dramatically. 

## Further Information

To get more insight into this project feel free to explore the [source code](https://github.com/sbudker/DVCS) or some of our internal docs on the [project wiki](https://github.com/sbudker/DVCS/wiki). These docs are missing significant chunks of project and team information so please read them with this in mind. 


## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.


## Authors

- **Aeshaan Wahlang** 
- **Simon Budker**
- **Wei Zhang**
- **Mingyang Jiao** 

See the list of [contributors](https://github.com/sbudker/DVCS/graphs/contributors) who participated in this project.

## Acknowledgments

Since this project is heavily based of mercurial. especially the original version, we 