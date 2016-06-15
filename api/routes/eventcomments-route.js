'use strict'

const express = require('express');
const router = express.Router({ mergeParams: true });

const events = require('../model/events');
const statuses = require('../util/statuses');
const errors = require('../util/errors');

router.get('/', function(req, res) {
  let eventId = req.query.eventid;
  return events.allCommentsForEventWithId(eventId).then(function(comment) => {
    res.json(comment);
  }).catch(errors.HttpHandler(res));;
});

router.post('/create', function(req, res) {
  let commentData = {
    text: req.body.text,
    event_id: req.query.eventid,
    author_id: req.user.id
  };

  events.createComment(commentData).then(function(comment) {
    res.status(statuses.Created).json(comment);
  }).catch(errors.HttpHandler(res));
});

module.exports = router;
