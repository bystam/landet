'use strict'

const knex = require('knex')({
  client: 'sqlite3',
  useNullAsDefault: true,
  connection: {
    filename: './database/db.sqlite3'
  }
})

const bookshelf = require('bookshelf')(knex);

module.exports = {
  bookshelf
};
