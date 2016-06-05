'use strict'

const Event = require('./entities').Event;
const Events = require('./entities').Events;

function allEvents() {
  return Events.forge()
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

module.exports = {
  allEvents,
  create
};
