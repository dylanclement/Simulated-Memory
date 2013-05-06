fs = require 'fs'
moment = require 'moment'
async = require 'async'
{log} = require './services/log.coffee'
_ = require 'underscore'
# [get]
# Gets the index page
exports.index = (req, res) ->
  res.render 'index', title: 'Simulation of Artificial Memory'

# [get]
# Gets the calculations page
exports.calculations = (req, res) ->
  res.render 'calculations', title: 'Simulation of Artificial Memory'

# [post]
# Save a relationship
exports.relationship = (req, res, next) ->
  body = req.body
  db = req.db
  db.create body.Obj, body.Rel, body.Sub, (err, obj, rel, sub) ->
    if err then return next err
    res.send "saved object #{obj.data.name} -> #{rel.type} -> #{sub.data.name}"

# [get]
# gets a grouped collection
exports.relationships = (req, res, next) ->
  db = req.db
  query = ['START n=node(*)',
    'MATCH n-[p]->m',
    'RETURN n.name as obj, TYPE(p) as rel, m.name as sub'].join '\n'
  db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results.map (result) ->
      [result.obj, result.rel, result.sub]

# [del]
# deletes a relationship
exports.deleteNode = (req, res, next) ->
  db = req.db
  obj = req.params.obj
  db.deleteObject obj, (err, result) ->
    if err then return next err
    if !result
      log.warn { obj }, 'Unable to find object to delete'

    res.send "Deleted object #{obj}"

# [del]
# deletes a relationship
exports.deleteRelationship = (req, res, next) ->
  db = req.db
  {obj, rel, sub} = req.params
  db.getRelationship obj, rel, sub, (err, result) ->
    if err then return next err
    if !result
      log.warn "Unable to find relationship to delete #{obj}->#{rel}->#{sub}"
      res.redirect 'back'

    result.delete null
    res.send "Deleted relationship #{obj}->#{rel}->#{sub}"

# [get]
# Gets all objects
exports.objects = (req, res, next) ->
  db = req.db
  db.getAllObjects (err, results) ->
    if err then return next err
    res.send results.map (result) ->
      item =
        name: result['n'].data.name
        access_count: result['n'].data.access_count
        created_at: moment(result['n'].data.created_at).calendar()

# [get]
# Gets data in a format that arbor.js can use to display in a graph
exports.getGraphDataArbor = (req, res, next) ->
  db = req.db
  query = ['START n=node(*)',
    'MATCH n-[p]->m',
    'RETURN n.name as obj, TYPE(p) as rel, m.name as sub'].join '\n'
  db.cypher query, {}, (err, results) ->
    if err then return next err
    data =
      nodes: {}
      edges: {}
    results.map (result) ->
      # Create the nodes
      data.nodes[result.obj] ?= {}
      data.nodes[result.sub] ?= {}

      # create the edges
      data.edges[result.obj] ?= {}
      data.edges[result.obj][result.sub] =
        # set the name and weight for the edges
        weight: 0.5
        name: result.rel.replace '_', ' '

    res.json data

# [get]
# Clears the database
exports.clearDB = (req, res, next) ->
  db = req.db
  db.clear (err) ->
    if err then return next err
    res.send 'Cleared database.'

# [get]
# gets a grouped collection
exports.categories = (req, res, next) ->
  db = req.db
  query = ['START n=node(*)',
    'MATCH n-[:is_a]->m',
    'RETURN m.name as name, count(m) as num'].join '\n'
  db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results

# [get]
# gets a grouped collection
exports.relations = (req, res, next) ->
  db = req.db
  query = ['START n=node(*)',
     'MATCH p=n-->o<--m',
     'RETURN n.name, m.name, count(p) as countp',
     'ORDER BY countp DESC'].join '\n'
  db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results

# [get]
# gets relationships ordered by use
exports.getRelationshipsOrderedByUse = (req, res, next) ->
  db = req.db
  query = 'START n=node(*) MATCH (n)-[r]->() RETURN type(r) as name, count(*) as num_uses'
  db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results

exports.saveToFile = (req, res, next) ->
  db = req.db
  db.getAllRelationships (err, results) ->
    if err then return next err
    resJSON = JSON.stringify(results)
    fs.writeFile "data/relations.json", resJSON, (err) ->
      if err then return next err
      res.send resJSON

fileLoad = (rwq, res, next, db, fileName) ->
  fs.readFile fileName, 'utf8', (err, resJSON) ->
    if err then return next err
    results = JSON.parse resJSON
    res.send results
    # build an array of methods to run and run them in series since we can't lock and don't want to add duplicate items
    cbs = []
    for ors in results
      do (ors) ->
        cbs.push (callback) ->
          db.create ors.obj, ors.rel, ors.sub, callback
    async.series cbs

exports.execCypher = (req, res, next) ->
  db = req.db
  query = req.body.query
  db.cypher query, {}, (err, results) ->
    if err then return next err
    res.json results

exports.editGraph = (req, res, next) ->
  res.render 'editGraph', title: 'Simulation of Artificial Memory'

exports.loadFromFile = (req, res, next) ->
  fileLoad req, res, next, req.db, 'data/relations.json'

exports.loadDemoFromFile = (req, res, next) ->
  fileLoad req, res, next, req.db, 'data/demo-relations.json'
