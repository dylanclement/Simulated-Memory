neo4j = require 'neo4j'

module.exports = class GraphDB
  constructor: (url, @logger, dbname) ->
    @db = new neo4j.GraphDatabase url
  
  command: (cmd, params, callback) =>
    @db.execute cmd, params, callback

  getObject: (id, callback) =>
    @db.getNodeById id, (err, results) ->
      if err
        return null
      else
        callback err, results

  createObject: (obj, callback) =>
    node = @db.createNode obj
    node.save callback
    @logger.info "Created vertex", name: obj.name

  createRelation: (obj, sub, relationship, callback) =>
    obj.createRelationshipTo sub, relationship, access_count : 1, (err, rel) =>
      rel.save callback
      @logger.info "Created edge", name: relationship

  getOutRelations: (node, callback) ->
    node.outgoing callback

  getInRelations: (node, callback) ->
    node.incoming callback

  getAllObjects: (callback) =>
    @db.execute 'select from OGraphVertex', callback
    
  getAllObjects: (callback) =>
    @db.execute 'g.V', callback

  updateAccessCount: (obj, callback) ->
    node.data.access_count += 1
    node.save callback
      