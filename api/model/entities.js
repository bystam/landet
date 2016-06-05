'use strict'

const bookshelf = require('./bookshelf').bookshelf;

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

const Location = bookshelf.Model.extend({
  tableName: 'locations',
  events: function() {
    return this.hasMany(Event);
  }
});

const Event = bookshelf.Model.extend({
  tableName: 'events',
  creator: function() {
    return this.belongsTo(User);
  },
  location: function() {
    return this.belongsTo(Location);
  },
  comments: function() {
    return this.hasMany(EventComment);
  }
});

const EventComment = bookshelf.Model.extend({
  tableName: 'event_comments',
  author: function() {
    return this.belongsTo(User);
  },
  event: function() {
    return this.belongsTo(Event);
  }
});

module.exports = {
  User,
  Session,
  Location,
  Event,
  EventComment
};
