winston = require 'winston'
moment = require 'moment'
winston.add winston.transports.File, filename: "logs/#{new moment().format('YYYYMMDDHHmmss')}.log"
exports.log = winston
