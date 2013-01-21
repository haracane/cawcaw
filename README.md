# Cawcaw

Cawcaw supports munin plugin for Hadoop/RabbitMQ.

## Supported Ruby versions and implementations
Cawcaw should work identically on:

* Ruby 1.9.3
* Ruby 1.9.2
* Ruby 1.8.7

## Install

You can install cawcaw by gem.

    gem install cawcaw

## Usage

### Draw munin graph of MySQL table record size
    cawcaw mysql table [--host host] [--port port]
                       [--username username] [--password password]
                       [--database database] [--encoding encoding]
                       table <table-name[,table-name...]> [autoconf|config]

### Draw munin graph of PostgreSQL table record size
    cawcaw postgresql table [--host host] [--port port]
                            [--username username] [--password password]
                            [--database database] [--encoding encoding]
                            table <table-name[,table-name...]> [autoconf|config]

### Draw munin graph of Hadoop HDFS size
    cawcaw hadoop dfs <hdfs-path[,hdfs-path...]> [autoconf|config]

### Draw munin graph of RabbitMQ queue message count
    cawcaw rabbitmq queue-count <queue-name[,queue-name...]> [autoconf|config]

## Contributing to cawcaw
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Kenji Hara. See LICENSE.txt for
further details.

