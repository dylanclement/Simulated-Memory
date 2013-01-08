neo4j = require 'neo4j'

module.exports = class GraphDB
  constructor: (url, @logger, dbname) ->
    @db = new neo4j.GraphDatabase url
  
  command: (cmd, params, callback) =>
    @db.execute cmd, params, callback

  clear: =>
    @logger.info 'Clearing database'
    query = [
      'START n=node(*)',
      'MATCH n-[r?]-()',
      'DELETE n, r'
    ].join '\n'
    @db.query query, {}, (err, results) ->
      throw err if err

  getObject: (id, callback) =>
    @db.getNodeById id, (err, results) ->
      if err
        return null
      else
        callback err, results

  createObject: (obj, callback) =>
    # see if the object exists
    @db.getIndexedNode 'object_auto_index', 'name', obj.name, (err, node) =>
      if node
        # object exists so increment the access count
        @logger.info "Returning object #{obj.name}"
        node.access_count += 1
        node.save callback
      else if err and err.message.exception == 'NotFoundException'
        # object doesn't exist so create it
        node = @db.createNode obj
        node.save callback
        # TODO! could potentially insert a duplicate object before we've created an index
        node.index 'object_auto_index', 'name', obj.name
        @logger.info "Created object #{obj.name}"
      else if err
        @logger.error err.exception.message, err
        throw err 


  createRelation: (obj, sub, relationship, callback) =>
    relName = "#{obj.name}->#{relationship}->#{sub.name}"
    # see if the relationship exists, if it does increment the access count, otherwise create it
    @db.getIndexedRelationship 'relationship_auto_index', relationship, relName, (err, rel) =>
      if rel
        @logger.info "Relationship #{relName} exists, incrementing access count."
        rel.data.access_count += 1
        rel.save callback
      else
        obj.createRelationshipTo sub, relationship, access_count : 1, (err, rel) =>
          rel.save callback
          # todo could potentially insert a duplicate relationship before we've created an index
          rel.index 'relationship_auto_index', relationship, relName
          @logger.info "Created edge #{relName}"
      if err
        @logger.error err.exception.message, err
        throw err

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
      