in4mahcy
========

# What?#
Uses a graph database to store information, with all information either represented as an object or a relationship between objects, for example:

    dog                                    is_a                                     animal
      access_count: 5                         access_count: 123                        access_count: 43
      created_at: now.addYears(-5)   -->>     created_at: now             -->>         created_at: now.addYears(-8)
      created_by: Reading Wikipedia           created_by: Data Entry # 123             created_by: parent

# How?#
Data is entered using object->relation->subject
These relations are stores in the database, and can be queried, for example:

    #to get potential 'categories' run this Gremlin query
    ```g.V.out(out_name).name.groupCount().cap```

All entries include a limited set of meta_data, which are attributes shared by all related entities (eg. access_count, created_at, created_by, weight).

As much data as possible is saved, even accessing data modifies and adds to it, therefore the same query done seconds apart could yield different results.

# Project Board#
https://trello.com/board/a-n-t/505e5311349fc8d53ecdf5dd

# Installation#
install node.js - I suggest using NVM for this, https://github.com/creationix/nvm

install coffeescript - npm install -g coffee-script

install and run neo4j - http://www.neo4j.org/install

now the application can be run by browsing to the project folder and running ```npm start```

#Dependencies#

https://github.com/thingdom/node-neo4j

https://github.com/tinkerpop/gremlin/wiki

https://github.com/visionmedia/express
