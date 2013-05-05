in4mahcy
========

# What?#
In4mahcy is an information management experiment that combines a graph database to store information and an asynchronous control centre to handle large volumes of operations.

Al information will in its simples form be represented as a relationship between an object and a subject, for example:

    dog                                    is_a                                     animal
      access_count: 5                         access_count: 123                        access_count: 43
      created_at: now.addYears(-5)   -->>     created_at: now             -->>         created_at: now.addYears(-8)
      created_by: Online article              created_by: data entry # 123             created_by: parent

This serves as a building block to build vast volumes of interconnected nodes, that can be queried and checked for patterns.

# Screenshot#

![screenshot](https://github.com/dylanclement/in4mahcy/raw/master/src/public/images/screenshot.png 'Screenshot of the app')

# Project Board#
https://trello.com/board/a-n-t/505e5311349fc8d53ecdf5dd

Big ticket items include:
 - User sign on (need to determine best way to segment data).
 - Query section to have the app ask questions (are cats and dogs related? if not, why) to better understand data.

# Installation#
install node.js - I suggest using NVM for this, https://github.com/creationix/nvm

install coffeescript - npm install -g coffee-script

install and run neo4j - http://www.neo4j.org/install

run the app with ```npm start```
