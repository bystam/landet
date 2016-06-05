
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
      host     : 'ec2-54-228-219-2.eu-west-1.compute.amazonaws.com',
      user     : 'hgznctmjjryuvs',
      password : process.env.LANDET_DEV_DB_PW,
      database : 'd403dmetsr9t9q',
      port     : 5432,
      charset  : 'utf8'
    }
  }
}
