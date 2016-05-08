'use strict'

const bookshelf = require('./bookshelf').bookshelf;

const Day = bookshelf.Model.extend({
  tableName: 'days',
  posts: function() {
    return this.hasMany(Post);
  }
});

const Post = bookshelf.Model.extend({
  tableName: 'posts',
  hasTimestamps: true,
  day: function () {
    return this.belongsTo(Day);
  }
});

module.exports = {
  Day,
  Post
};
