# CoffeeScript
exports.new = (req, res, relationship, @logger) ->
  body = req.body
  res.send 'saved object #{body.Obj} -> #{body.Rel} #{body.Sub}'