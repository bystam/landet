'use strict'

const bookshelf = require('./bookshelf').bookshelf;

const User = bookshelf.Model.extend({
  tableName: 'users',
  hasTimestamps: true,
  sessions: function() {
    return this.hasMany(Session, 'user_id');
  }
});

const Users = bookshelf.Collection.extend({
  model: User
});


const Session = bookshelf.Model.extend({
  tableName: 'sessions',
  user: function() {
    return this.belongsTo(User, 'user_id');
  }
});

const Sessions = bookshelf.Collection.extend({
  model: Session
});


const Location = bookshelf.Model.extend({
  tableName: 'locations',
  events: function() {
    return this.hasMany(Event, 'location_id');
  }
});

const Locations = bookshelf.Collection.extend({
  model: Location
});


const Event = bookshelf.Model.extend({
  tableName: 'events',
  creator: function() {
    return this.belongsTo(User, 'creator_id');
  },
  location: function() {
    return this.belongsTo(Location, 'location_id');
  },
  comments: function() {
    return this.hasMany(EventComment, 'event_id');
  }
});

const Events = bookshelf.Collection.extend({
  model: Event
});


const EventComment = bookshelf.Model.extend({
  tableName: 'event_comments',
  author: function() {
    return this.belongsTo(User, 'author_id');
  },
  event: function() {
    return this.belongsTo(Event, 'event_id');
  }
});

const EventComments = bookshelf.Collection.extend({
  model: EventComment
});


module.exports = {
  User,
  Users,
  Session,
  Sessions,
  Location,
  Locations,
  Event,
  Events,
  EventComment,
  EventComments
};
