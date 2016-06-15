'use strict'

const Event = require('./entities').Event;
const Events = require('./entities').Events;

const EventComment = require('./entities').EventComment;
const EventComments = require('./entities').EventComments;

function allEvents() {
  return Events.query('orderBy', 'event_time')
    .fetch({
      withRelated: [
        'location',
        { creator: (q) => q.select(['id', 'username', 'name']) }
      ]
    });
}

function create(eventData) {
  return Event.forge(eventData).save();
}

function allCommentsForEventWithId(eventId) {
  return Event.forge({ id: eventId }).comments()
  .query('orderBy', 'comment_time')
  .fetch({
      withRelated: [
        { author: (q) => q.select(['id', 'username', 'name']) }
      ]
    });
}

function createComment(commentData) {
  return EventComment.forge(commentData).save();
}

module.exports = {
  allEvents,
  create,
  allCommentsForEventWithId,
  createComment
};
