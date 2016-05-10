'use strict'

let knexConfig = {};

const db = process.env.LANDET_DB

if (db === 'heroku_dev') {

  console.log('--- knex --- heroku dev db');

  knexConfig = {
    client: 'pg',
    connection: {
      host     : 'ec2-54-228-219-2.eu-west-1.compute.amazonaws.com',
      user     : 'scemjrevdeifas',
      password : 'CKeOr_s8VobQJaHSf_hooCYooV',
      database : 'd403dmetsr9t9q',
      port     : 5432,
      charset  : 'utf8'
    }
  };

} else {
  console.log('--- knex --- local sqlite db');

  knexConfig = {
    client: 'sqlite3',
    useNullAsDefault: true,
    connection: {
      filename: './database/db.sqlite3'
    }
  };
}

const knex = require('knex')(knexConfig)
const bookshelf = require('bookshelf')(knex);

module.exports = {
  bookshelf
};
