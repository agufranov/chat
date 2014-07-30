module.exports =
  startPort: 20100
  processes: 5
  db:
    connectionString: "postgres://postgres:root@localhost/chat_archive"
  redis:
    port: 6379
    host: "localhost"
