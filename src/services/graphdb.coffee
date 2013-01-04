neo4j = require 'neo4j'

module.exports = class GraphDB
  constructor: (url, @logger, dbname) ->
    @db = neo4j.GraphDatabase url
  
  open: (callback) -> 
    return callback err

  #close: -> 

  command: (cmd, params, callback) ->
    @db.execute cmd, params, callback

  #clear: (callback) ->

  getObject: (id, callback) ->
    @db.getNodeById id, (err, results) ->
      if err
        return null
      else
        callback err, results

  createObject: (obj, callback) ->
    node = @db.createNode obj
    node.save callback
    @logger.info "Created vertex", name: obj.name

  createRelation: (obj, sub, relationship, callback) ->
    rel = obj.createRelationshipTo sub, relationship, access_count : 1 
    rel.save callback
    @logger.info "Created edge", name: relationship.name

  getOutRelations: (node, callback) ->
    node.outgoing callback

  getInRelations: (node, callback) ->
    node.incoming callback

  getAllObjects: (callback) ->
    @command 'select from OGraphVertex', callback
    
  getAllObjects: (callback) ->
    @db.execute 'g.V', callback

  updateAccessCount: (obj, callback) ->
    node.data.access_count += 1
    node.save callback
      