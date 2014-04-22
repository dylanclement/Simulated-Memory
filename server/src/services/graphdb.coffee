neo4j = require 'neo4j'
{log} = require './log'

module.exports = class GraphDB

  constructor: (url, dbname) ->  @db = new neo4j.GraphDatabase url

  OBJ_INDEX_NAME: 'objects'
  REL_INDEX_NAME: 'relationships'

  # Runs a gremlin query
  gremlin: (cmd, params, cb) -> @db.execute cmd, params, cb

  # Runs a cypher query
  cypher: (cmd, params, cb) -> @db.query cmd, params, cb

  
  # Clears all the data from the db
  clear: (cb = ->) ->
    log.info 'Clearing database'
    query = [
      'START n=node(*)',
      'MATCH n-[r?]-()',
      'DELETE n, r'
    ].join '\n'
    @db.query query, nodes: '*', (err, results) ->
      if err then return cb err
      return cb null

  
  # Gets an object from the db
  getObject: (name, cb) ->
    query = [
      'MERGE (node { name: {name}})',
      'ON CREATE SET node.created_at = timestamp()',
      'ON MATCH SET node.accessCount = node.accessCount + 1',
      'RETURN node;',
    ].join '\n'
    @db.query query, {name}, (err, results) ->
      if err then return cb err
      log.info { name: results[0].node._data.data }, 'Created object.'
      return cb null, results[0].node._data.data

  
  # Deletes a object
  deleteObject: (name, cb) ->
    query = [
      'MATCH (node { name: {name}})',
      'OPTIONAL MATCH (node)-[rel]-()',
      'DELETE node, rel'
    ].join '\n'
    log.info 'Deleting node', name
    @db.query query, {name}, (err, results) ->
      if err then return cb err
      log.info { results }, 'Deleted object.'
      return cb null, results


  # Creates a relationship between two objects
  createRelation: (obj, rel, sub, cb) ->
    query = [
      'MATCH (obj { name: {obj}}),(sub {name: {sub}})',
      "MERGE (obj)-[rel:#{rel}]->(sub)",
      'RETURN obj, rel, sub'
    ].join '\n'
    log.info 'Creating relationship',obj, '->', rel, '->', sub
    @db.query query, {obj, sub}, (err, results) ->
      if err then return cb err
      log.info { results }, 'Deleted object.'
      return cb null, results

  # Shorthand for creating a obj-rel-sub
  create: (objName, relName, subName, cb) ->
    log.info "Creating #{objName}, #{relName}, #{subName}"
    @getObject objName, (err, obj) =>
      if err then return cb err

      @getObject subName, (err, sub) =>
        if err then return cb err

        @createRelation obj.name, relName, sub.name, (err, rel) ->
          if err then return cb err

          cb null, obj.name, relName, sub.name


  # Gets all outgoing relationships from a node
  getOutRelations: (node, cb) ->  node.outgoing cb

  # Gets all incoming relationships from a node
  getInRelations: (node, cb) ->  node.incoming cb

  # Gets all the objects in the db
  getAllObjects: (cb) ->
    query = [
      'START n=node(*)',
      'RETURN n'].join '\n'
    @db.query query, nodes: '*', (err, results) ->
      if err then return cb err
      cb null, results

  # Gets all relationships stored in the db
  getAllRelationships: (cb) ->
    query = [
      'START n=node(*)',
      'MATCH n-[r]->m',
      'RETURN n.name as obj, type(r) as rel, m.name as sub'].join '\n'
    @db.query query, {}, (err, results) ->
      if err then return cb err
      cb null, results
