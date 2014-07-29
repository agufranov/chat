# Отвечает за аутентификацию и авторизацию пользователей.
class AuthProvider
  @authorize: (handshake, accept) ->
    uid = handshake._query.uid
    if uid?
      accept null, true
    else
      accept "uid is missing", false

module.exports = AuthProvider
