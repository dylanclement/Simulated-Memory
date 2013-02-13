neo4j = require 'neo4j'
moment = require 'moment'

module.exports = class GraphDB

  constructor: (url, @logger, dbname) ->
    @db = new neo4j.GraphDatabase url

  OBJ_INDEX_NAME: 'objects'
  REL_INDEX_NAME: 'relationships'

  ###
  Runs a gremlin query
  ###
  gremlin: (cmd, params, callback) =>
    @db.execute cmd, params, callback

  ###
  Runs a cypher query
  ###
  cypher: (cmd, params, callback) =>
    @db.query cmd, params, callback

  ###
  Clears all the data from the db
  ###
  clear: =>
    @logger.info 'Clearing database'
    query = [
      'START n=node(*)',
      'MATCH n-[r?]-()',
      'DELETE n, r'
    ].join '\n'
    @db.query query, nodes: '*', (err, results) ->
      throw err if err

  ###
  Gets an object from the db
  ###
  getObject: (name, callback) =>
    # see if the object exists
    @db.getIndexedNode @OBJ_INDEX_NAME, 'name', name, (err, node) =>
      if (err and err.message.exception == 'NotFoundException') or (!err and !node)
        # object doesn't
        callback null, null
        @logger.info "Node #{name} doesn't exist"
      else if err
        @logger.error err.exception.message, err
        throw err

  ###
  Creates an object
  ###
  createObject: (obj, callback) =>
    # see if the object exists
    @db.getIndexedNode @OBJ_INDEX_NAME, 'name', obj.name, (err, node) =>
      if (err and err.message.exception == 'NotFoundException') or (!err and !node)
        # object doesn't exist so create it
        obj.created_at = new Date
        node = @db.createNode obj
        node.save (err, savedNode) =>
          # TODO! could potentially insert a duplicate object before we've created an index
          savedNode.index @OBJ_INDEX_NAME, 'name', obj.name, (err, indexedNode) =>
            callback null, savedNode
        @logger.info "Created object #{obj.name}"
      else if err
        @logger.error err.exception.message, err
        throw err
      else if node
        # object exists so increment the access count
        @logger.info "Returning object #{obj.name}"
        node.data.access_count += 1
        node.save callback

  ###
  Gets a relationship between two objects
  ###
  createRelation: (obj, sub, relationship, callback) =>
    relName = "#{obj.data.name}->#{relationship}->#{sub.data.name}"
    # see if the relationship exists, if it does increment the access count, otherwise create it
    @db.getIndexedRelationship @REL_INDEX_NAME, relationship, relName, (err, rel) =>
      if (err and err.message.exception == 'NotFoundException') or (!err and !rel)
        # relationship doesn't exist so create it
        obj.createRelationshipTo sub, relationship, { access_count : 0, created_at : new Date }, (err, rel) =>
          rel.save (err, savedRel) =>
            # todo could potentially insert a duplicate relationship before we've created an index
            savedRel.index @REL_INDEX_NAME, relationship, relName, (err, indexedRel) =>
              callback null, savedRel
          @logger.info "Created edge #{relName}"
      else if err
        @logger.error err.exception.message, err
        throw err
      else if rel
        @logger.info "Relationship #{relName} exists, incrementing access count."
        rel.data.access_count += 1
        rel.save callback

  ###
  Shorthand for creating a obj-rel-sub
  ###
  create: (objName, subName, relName) =>
    @createObject { name: objName, access_count: 0 }, (err, obj) =>
      if err then throw err
      @createObject { name: subName, access_count: 0 }, (err, sub) =>
        if err then throw err
        @createRelation obj, sub, relName, (err, rel) =>
          if err then throw err
          res.send 'saved object #{obj} -> #{rel} #{sub}'


  ###
  Gets all outgoing relationships from a node
  ###
  getOutRelations: (node, callback) ->
    node.outgoing callback

  ###
  Gets all incoming relationships from a node
  ###
  getInRelations: (node, callback) ->
    node.incoming callback

  ###
  Gets all the objects in the db
  ###
  getAllObjects: (callback) =>
    query = [
      'START n=node(*)',
      'RETURN n'
    ].join '\n'
    @db.query query, nodes: '*', (err, results) ->
      if err then throw err
      callback null, results.map (result) ->
        "name = #{result['n'].data.name}, access_count = #{result['n'].data.access_count}, created_at = #{moment(result['n'].data.created_at).calendar()}"
