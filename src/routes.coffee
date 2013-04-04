fs = require 'fs'
moment = require 'moment'
async = require 'async'
# [get]
# Gets the index page
exports.index = (req, res) ->
  res.render 'index', title: 'In4mahcy'

# [get]
# Gets the calculations page
exports.calculations = (req, res) ->
  res.render 'calculations', title: 'In4mahcy'

# [push]
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
  body = req.body
  db = req.db
  query = ['START n=node(*)',
    'MATCH n-[p]->m',
    'RETURN n.name as obj, TYPE(p) as rel, m.name as sub'].join '\n'
  db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results.map (result) ->
        [result.obj, result.rel, result.sub]

# [get]
# Gets all objects
exports.objects = (req, res, next) ->
  body = req.body
  db = req.db
  db.getAllObjects (err, results) ->
    if err then return next err
    res.send results.map (result) ->
      item =
        name: result['n'].data.name
        access_count: result['n'].data.access_count
        created_at: moment(result['n'].data.created_at).calendar()

# [get]
# Clears the database
exports.clearDB = (req, res, next) ->
  body = req.body
  db = req.db
  db.clear (err) ->
    if err then return next err
    res.send 'Cleared database.'

# [get]
# gets a grouped collection
exports.categories = (req, res, next) ->
  body = req.body
  db = req.db
  query = ['START n=node(*)',
    'MATCH n-[:is_a]->m',
    'RETURN m.name as name, count(m) as num'].join '\n'
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
  body = req.body
  db = req.db
  db.getAllRelationships (err, results) ->
    if err then return next err
    resJSON = JSON.stringify(results)
    fs.writeFile "data/relations.json", resJSON, (err) ->
      if err then return next err
      res.send resJSON

exports.loadFromFile = (req, res, next) ->
  body = req.body
  db = req.db
  fs.readFile "data/relations.json", 'utf8', (err, resJSON) ->
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

