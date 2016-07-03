'use strict'

const knexConfigs = require('../database/knexfile');

let knexConfig = null;
const db = process.env.LANDET_DB;

if (db === 'heroku_dev') {
  knexConfig = knexConfigs.heroku_dev;
} else {
  knexConfig = knexConfigs.development;
}

const knex = require('knex')(knexConfig);
const bookshelf = require('bookshelf')(knex);

bookshelf.plugin('visibility');

knex.migrate.latest({
  directory: './database/migrations'
});

module.exports = {
  bookshelf
};
