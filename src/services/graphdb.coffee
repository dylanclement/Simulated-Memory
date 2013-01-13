neo4j = require 'neo4j'

module.exports = class GraphDB
  constructor: (url, @logger, dbname) ->
    @db = new neo4j.GraphDatabase url
  
  OBJ_INDEX_NAME: 'objects'
  REL_INDEX_NAME: 'relationships'

  command: (cmd, params, callback) =>
    @db.execute cmd, params, callback

  clear: =>
    @logger.info 'Clearing database'
    query = [
      'START n=node(*)',
      'MATCH n-[r?]-()',
      'DELETE n, r'
    ].join '\n'
    @db.query query, nodes: '*', (err, results) ->
      throw err if err

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

  createObject: (obj, callback) =>
    # see if the object exists
    @db.getIndexedNode @OBJ_INDEX_NAME, 'name', obj.name, (err, node) =>
      if (err and err.message.exception == 'NotFoundException') or (!err and !node)
        # object doesn't exist so create it
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

  createRelation: (obj, sub, relationship, callback) =>
    relName = "#{obj.data.name}->#{relationship}->#{sub.data.name}"
    # see if the relationship exists, if it does increment the access count, otherwise create it
    @db.getIndexedRelationship @REL_INDEX_NAME, relationship, relName, (err, rel) =>
      if (err and err.message.exception == 'NotFoundException') or (!err and !rel)
        # object doesn't exist so create it
        obj.createRelationshipTo sub, relationship, access_count : 0, (err, rel) =>
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

  getOutRelations: (node, callback) ->
    node.outgoing callback

  getInRelations: (node, callback) ->
    node.incoming callback
    
  getAllObjects: (callback) =>
    @db.execute 'g.V', callback


      