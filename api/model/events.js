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
  return Event.where({ id: eventId }).comments().fetch();
}

function createComment(commentData) {
  return EventComment.forge(eventdata).save();
}

module.exports = {
  allEvents,
  create,
  allCommentsForEventWithId,
  createComment
};
