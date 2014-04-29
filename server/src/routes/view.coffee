express = require 'express'

view = express.Router()

# [get /view/home]
# Gets the index page
view.get '/home', (req, res, next) -> res.render 'index', title: 'Simulated Memory'

# [get /view/calculations]
# Gets the calculations page
view.get '/calculations', (req, res, next) -> res.render 'calculations', title: 'Simulated Memory Calculations'

# [get /view/edit-graph]
# Gets the edit graph page
view.get '/edit-graph', (req, res, next) -> res.render 'editGraph', title: 'Edit Simulated Memory'

module.exports = view
