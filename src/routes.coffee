# [get]
# Gets the index page
exports.index = (req, res) ->
  res.render 'index', title: 'In4mahcy'# CoffeeScript

# [push]
# Save a relationship
exports.relationship = (req, res) ->
  body = req.body
  db = req.db
  db.createObject { name: body.Obj, access_count: 0 }, (err, obj) ->
    if err
      console.log err
      return
    db.createObject { name: body.Sub, access_count: 0 }, (err, sub) ->
      if err
        console.log err
        return
      db.createRelation obj, sub, body.Rel, (err, rel) ->
        if err
          console.log err
          return
        res.send 'saved object #{obj} -> #{rel} #{sub}'

# [push]
# Save a relationship
exports.relationships = (req, res) ->
  body = req.body
  db = req.db
  db.getAllObjects (err, results) ->
    res.send results

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
  query = ['g.V.out(out_name).name.groupCount().cap'].join '\n'
  db.gremlin query, out_name : 'is_a', (err, results) ->
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


