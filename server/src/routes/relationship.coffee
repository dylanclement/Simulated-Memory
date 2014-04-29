express = require 'express'
moment = require 'moment'
{log} = require '../services/log'

relationship = express.Router()

# [post /relationship/:obj/:rel/:sub]
# Save a relationship
relationship.post '/:obj/:rel/:sub', (req, res, next) ->
  {obj, rel, sub} = req.params
  req.db.create obj, rel, sub, (err, obj, rel, sub) ->
    if err then return next err
    res.send "saved object #{obj} -> #{rel} -> #{sub}"

# [get /relationship/*/*/*]
# gets all relationships
relationship.get '/*/*/*', (req, res, next) ->
  query = 'START n=node(*)
    MATCH n-[p]->m
    RETURN n.name as obj, TYPE(p) as rel, m.name as sub'
  req.db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results.map (result) ->
      [result.obj, result.rel, result.sub]

# [del /relationship/:obj]
# deletes a node
relationship.delete '/:obj', (req, res, next) ->
  {obj} = req.params
  req.db.deleteObject obj, (err, result) ->
    if err then return next err
    if !result
      log.warn { obj }, 'Unable to find object to delete'

    res.send "Deleted object #{obj}"

# [del /relationship/:obj/:rel/:sub]
# deletes a relationship
relationship.delete '/:obj/:rel/:sub', (req, res, next) ->
  {obj, rel, sub} = req.params
  req.db.getRelationship obj, rel, sub, (err, result) ->
    if err then return next err
    if !result
      log.warn "Unable to find relationship to delete #{obj}->#{rel}->#{sub}"
      res.redirect 'back'

    result.delete null
    res.send "Deleted relationship #{obj}->#{rel}->#{sub}"

# [get /relationship/*]
# Gets all objects
relationship.get '/*', (req, res, next) ->
  req.db.getAllObjects (err, results) ->
    if err then return next err
    res.send results.map (result) ->
      item =
        name: result['n'].data.name
        access_count: result['n'].data.access_count
        created_at: moment(result['n'].data.created_at).calendar()

# [del /relationship/*/*/*]
# Clears the database
relationship.delete '/*/*/*', (req, res, next) ->
  req.db.clear (err) ->
    if err then return next err
    res.send 'Cleared database.'

module.exports = relationship
