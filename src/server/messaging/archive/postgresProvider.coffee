pg = require "pg"

settings = require "../../settings"

# Слой базы данных для архивирования сообщений
class PostgresProvider
  constructor: ->
    client = new pg.Client settings.db.connectionString
    client.connect (err) ->
      if err
        console.log "PostgresProvider error: #{err}"

    @archiveMessage = (msg, callback) ->
      client.query "INSERT INTO messages (local_id, body, \"from\", \"to\", timestamp, read) VALUES ($1, $2, $3, $4, $5, $6)", [ msg.id, msg.body, msg.from, msg.to, msg.timestamp, false ], callback

    @markMessageAsRead = (id, callback) ->
      client.query "UPDATE messages set read = true WHERE local_id = $1", [ id ], callback

    @getHistory = (from, options, callback) ->
      client.query "WITH q AS (SELECT local_id, body, \"from\", \"to\", timestamp, read FROM messages) SELECT *, 'out' as direction FROM q WHERE \"from\" = $1 AND \"to\" = $2 UNION SELECT *, 'in' as direction FROM q WHERE \"from\" = $2 AND \"to\" = $1 ORDER BY TIMESTAMP DESC OFFSET $3 LIMIT $4", [ from, options.with, options.offset, options.limit ], callback

module.exports = PostgresProvider
