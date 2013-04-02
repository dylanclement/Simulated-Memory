fs = require 'fs'
moment = require 'moment'
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
exports.relationship = (req, res) ->
  body = req.body
  db = req.db
  db.create body.Obj, body.Rel, body.Sub, (err, obj, rel, sub) ->
    res.send "saved object #{obj.data.name} -> #{rel.database} -> #{sub.data.name}"

# [get]
# Gets all relationships
exports.relationships = (req, res) ->
  body = req.body
  db = req.db
  db.getAllObjects (err, results) ->
    res.send results.map (result) ->
        "name = #{result['n'].data.name}, access_count = #{result['n'].data.access_count}, created_at = #{moment(result['n'].data.created_at).calendar()}"

# [get]
# Clears the database
exports.clearDB = (req, res) ->
  body = req.body
  db = req.db
  db.clear()
  res.send 'Cleared database.'

# [get]
# gets a grouped collection
exports.isCategory = (req, res) ->
  body = req.body
  db = req.db
  query = ['START n=node(*)',
    'MATCH n-[:is_a]->m',
    'RETURN m.name, count(m)'].join '\n'
  db.cypher query, {}, (err, results) ->
    console.log err, results
    res.send results

# [get]
# gets relationships ordered by use
exports.getRelationshipsOrderedByUse = (req, res) ->
  db = req.db
  query = 'START n=node(*) MATCH (n)-[r]->() RETURN type(r) as name, count(*) as num_uses'
  db.cypher query, {}, (err, results) ->
    console.log err, results
    res.send results

exports.saveToFile = (req, res) ->
  body = req.body
  db = req.db
  db.getAllRelationships (err, results) ->
    resJSON = JSON.stringify(results)
    fs.writeFile "data/relations.json", resJSON, (err) ->
      if err then throw err
      res.send resJSON

exports.loadFromFile = (req, res) ->
  body = req.body
  db = req.db
  fs.readFile "data/relations.json", 'utf8', (err, resJSON) ->
    if err then throw err
    results = JSON.parse resJSON
    res.send results
    for ors in results
      db.create ors.obj, ors.rel, ors.sub

