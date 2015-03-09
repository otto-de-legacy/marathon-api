marathon-api
============

[![Gem Version](https://badge.fury.io/rb/marathon-api.svg)](http://badge.fury.io/rb/marathon-api) [![travis-ci](https://travis-ci.org/otto-de/marathon-api.png?branch=master)](https://travis-ci.org/otto-de/marathon-api) [![Code Climate](https://codeclimate.com/github/otto-de/marathon-api/badges/gpa.svg)](https://codeclimate.com/github/otto-de/marathon-api) [![Test Coverage](https://codeclimate.com/github/otto-de/marathon-api/badges/coverage.svg)](https://codeclimate.com/github/otto-de/marathon-api)

This gem provides an object oriented interface to the [Marathon Remote API][1]. At the time if this writing, marathon-api is meant to interface with Marathon version 0.8.0.

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'marathon-api',  :require => 'marathon'
```

And then run:

```shell
$ bundle install
```

Alternatively, if you wish to just use the gem in a script, you can run:

```shell
$ gem install marathon-api
```

Finally,  just add `require 'marathon'` to the top of the file using this gem.

Usage
-----

marathon-api is designed to be very lightweight. Only little state is cached to ensure that each method call's information is up to date. As such,  just about every external method represents an API call.

If you're running Marathon locally on port 8080,  there is no setup to do in Ruby. If you're not or change the path or port,  you'll have to point the gem to your socket or local/remote port. For example:

```ruby
Marathon.url = 'http://example.com:8080'
```

It's possible to use `ENV` variables to configure the endpoint as well:

```shell
$ MARATHON_URL=http://remote.marathon.example.com:8080 irb
irb(main):001:0> require 'marathon'
=> true
irb(main):002:0> Marathon.url
=> "http://remote.marathon.example.com:8080"
```

## Authentification

You have two options to set authentification if your Marathon API requires it:

```ruby
Marathon.options = {:username => 'your-user-name', :password => 'your-secret-password'}
```

or

```shell
$ export MARATHON_USER=your-user-name
$ export MARATHON_PASSWORD=your-secret-password
$ irb
irb(main):001:0> require 'marathon'
=> true
irb(main):002:0> Marathon.options
=> {:username => "your-user-name", :password => "your-secret-password"}
```

## Global calls

```ruby
require 'marathon'
# => true

Marathon.info
# => {"name"=>"marathon", "http_config"=>{"assets_path"=>null, "http_port"=>8080, "https_port"=>8443}, "frameworkId"=>"20150228-110436-16842879-5050-2169-0001", "leader"=>null, "event_subscriber"=>null, "marathon_config"=>{"local_port_max"=>20000, "local_port_min"=>10000, "hostname"=>"mesos", "master"=>"zk://localhost:2181/mesos", "reconciliation_interval"=>300000, "mesos_role"=>null, "task_launch_timeout"=>300000, "reconciliation_initial_delay"=>15000, "ha"=>true, "failover_timeout"=>604800, "checkpoint"=>true, "executor"=>"//cmd", "marathon_store_timeout"=>2000, "mesos_user"=>"root"}, "version"=>"0.8.0", "zookeeper_config"=>{"zk_path"=>"/marathon", "zk"=>null, "zk_timeout"=>10, "zk_hosts"=>"localhost:2181", "zk_future_timeout"=>{"duration"=>10}}, "elected"=>false}

Docker.ping
# => 'pong'

```

## Applications

You can list, change, delete apps like this:

```ruby
require 'marathon'

# fetch a list of applications
apps = Marathon::App.list

# scale the first app to 2 instances
apps.first.scale!(2)

# delete the last app
apps.last.delete!
```

The other Marathon endpoints are available in the same way.

Credits
-------

This gem is inspired by mesosphere's abondend [marathon_client][2] and swipelies [docker-api][3].

License
-------

This program is licensed under the MIT license. See LICENSE for details.

[1]: https://mesosphere.github.io/marathon/docs/rest-api.html
[2]: https://github.com/mesosphere/marathon_client
[3]: https://github.com/swipely/docker-api
