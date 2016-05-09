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
  day: function() {
    return this.belongsTo(Day);
  },
  user: function() {
    return this.belongsTo(User);
  }
});

const User = bookshelf.Model.extend({
  tableName: 'users',
  posts: function() {
    return this.hasMany(Post);
  },
  sessions: function() {
    return this.hasMany(Session);
  }
});

const Session = bookshelf.Model.extend({
  tableName: 'sessions',
  user: function() {
    return this.belongsTo(User);
  }
});

module.exports = {
  Day,
  Post,
  User, Session
};
