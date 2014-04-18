neo4j = require 'neo4j'
{log} = require './log.coffee'

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
    # see if the object exists
    @db.getIndexedNode @OBJ_INDEX_NAME, 'name', name, (err, node) =>
      if (err && /NotFoundException/.test err.message) || (!err && !node)
        # object doesn't exist
        log.info "Node #{name} doesn't exist"
        return cb null
      else if err
        return cb err
      else
        return cb null, node

  # Creates an object
  createObject: (obj, cb) ->
    # see if the object exists
    # @db.getIndexedNode @OBJ_INDEX_NAME, 'name', obj.name, (err, node) =>
    #   if (err && /NotFoundException/.test err.message) || (!err && !node)
    #     # object doesn't exist so create it
    #     obj.created_at = new Date
    #     node = @db.createNode obj
    #     node.save (err, savedNode) =>
    #       # TODO! could potentially insert a duplicate object before we've created an index
    #       savedNode.index @OBJ_INDEX_NAME, 'name', obj.name, (err, indexedNode) =>
    #         log.info { obj }, 'Created object.'
    #         cb null, savedNode
    #   else if err
    #     return cb err
    #   else if node
    #     # object exists so increment the access count
    #     log.info { obj }, 'Return existing object.'
    #     node.data.access_count += 1
    #     node.save cb
    query = [
      "MERGE (node: name: #{obj.name})",
      'RETURN node'
    ].join '\n'
    @db.query query, {obj}, (err, results) ->
      if err then return cb err
      log.info { obj }, 'Created object.'
      return cb null

  # Deletes a object
  deleteObject: (obj, cb) ->
    @getObject obj, (err, result) ->
      if err then return cb err
      if !result
        log.warn { obj }, 'Unable to find object to delete'
        return cb null

      delFunc = (err) ->
        if err then return cb err
        log.info { obj }, 'Deleted object'
        cb null, obj

      result.delete delFunc, true

  # Gets a relationship between two objects
  getRelationship: (obj, sub, relationship, cb) ->
    relName = "#{obj}->#{relationship}->#{sub}"
    @db.getIndexedRelationship @REL_INDEX_NAME, relationship, relName, (err, rel) =>
      if (err && /NotFoundException/.test err.message) || (!err && !rel)
        #log.info { obj, relationship, sub}, 'Attempt to get relationship that doesn\'t exist'
        return cb null
      else if err
        return cb err
      else if rel
        cb null, rel

  # Creates a relationship between two objects
  createRelation: (obj, sub, relationship, cb) ->
    relName = "#{obj.data.name}->#{relationship}->#{sub.data.name}"
    log.info "Creating Relationship #{obj.data.name}, #{relationship}, #{sub.data.name}"
    @getRelationship obj.data.name, sub.data.name, relationship, (err, rel) =>
      if err then return cb err
      if rel
        log.info "Relationship #{relName} exists, incrementing access count."
        rel.data.access_count += 1
        rel.save cb
      else
        # relationship doesn't exist so create it
        obj.createRelationshipTo sub, relationship, { access_count : 0, created_at : new Date }, (err, rel) =>
          if err then return cb err

          rel.save (err, savedRel) =>
            if err then return cb err

            # todo could potentially insert a duplicate relationship before we've created an index
            log.info "Created edge #{relName}"
            savedRel.index @REL_INDEX_NAME, relationship, relName, (err) ->
              if err then return cb err

              cb null, rel

  # Shorthand for creating a obj-rel-sub
  create: (objName, relName, subName, cb) ->
    log.info "Creating #{objName}, #{relName}, #{subName}"
    @createObject { name: objName, access_count: 0 }, (err, obj) =>
      if err then return cb err

      @createObject { name: subName, access_count: 0 }, (err, sub) =>
        if err then return cb err

        @createRelation obj, sub, relName, (err, rel) =>
          if err then return cb err

          cb null, obj, rel, sub


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
