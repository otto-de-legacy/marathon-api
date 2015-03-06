# Prerequisites
To develop on this gem, you must the following installed:
* a sane Ruby 1.9+ environment with `bundler`
```shell
$ gem install bundler
```
* Local Marathon v0.8.0 or greater running on Port 8080. Use [Vagrant][1] or [docker][2] to prevent local installation.



# Getting Started
1. Clone the git repository from Github:
```shell
$ git clone git@github.com:felixb/marathon-api.git
```
2. Install the dependencies using Bundler
```shell
$ bundle install
```
3. Create a branch for your changes
```shell
$ git checkout -b my_bug_fix
```
4. Make any changes
5. Write tests to support those changes.
6. Run the tests:
  * `bundle exec rake vcr:test`
7. Assuming the tests pass, open a Pull Request on Github.

# Using Rakefile Commands
This repository comes with five Rake commands to assist in your testing of the code.

## `rake spec`
This command will run Rspec tests normally on your local system. Be careful that VCR will behave "weirdly" if you currently have the Docker daemon running.

## `rake quality`
This command runs a code quality threshold checker to hinder bad code.

## `rake vcr`
This gem uses [VCR](https://relishapp.com/vcr/vcr) to record and replay HTTP requests made to the Docker API. The `vcr` namespace is used to record and replay spec tests inside of a Docker container. This will allow each developer to run and rerecord VCR cassettes in a consistent environment.

### `rake vcr:record`
This is the command you will use to record a new set of VCR cassettes. This command runs the following procedures:
1. Delete the existing `fixtures/vcr` directory.
2. Launch some tasks on local Marathon instance
3. Record new VCR cassettes by running the Rspec test suite against the local Marathon instance.

[1]: https://github.com/everpeace/vagrant-mesos
[2]: https://registry.hub.docker.com/u/mesosphere/marathon/