'use strict'

const bookshelf = require('./bookshelf').bookshelf;

const Day = bookshelf.Model.extend({
  tableName: 'days'
});

const Post = bookshelf.Model.extend({
  tableName: 'posts'
});

module.exports = {
  Day,
  Post
};
