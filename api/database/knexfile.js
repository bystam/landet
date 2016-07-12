
module.exports = {

  development: {
    client: 'postgresql',
    connection: {
      database: 'landet_dev'
    }
  },
  heroku_dev: {
    client: 'pg',
    connection: {
      host     : process.env.LANDET_DEV_DB_HOST,
      user     : process.env.LANDET_DEV_DB_USER,
      password : process.env.LANDET_DEV_DB_PW,
      database : process.env.LANDET_DEV_DB_DATABASE,
      port     : 5432,
      charset  : 'utf8'
    }
  }
}
