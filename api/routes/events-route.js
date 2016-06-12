'use strict'

const express = require('express');
const router = express.Router();
const events = require('../model/events');

const errors = require('../util/errors');
const statuses = require('../util/statuses');

const comments = require('./eventcomments-route');
router.use('/:eventid/comments', comments);

function logError(e) {
  console.log(e);
}

router.get('/', function(req, res) {
  events.allEvents().then(function(events) {
    res.json(events.toJSON());
  }).catch(errors.HttpHandler(res));;
});

router.post('/create', function(req, res) {
  let eventData = {
    title: req.body.title,
    body: req.body.body,
    location_id: req.body.location_id,
    event_time: req.body.event_time,
    creator_id: req.user.id
  };

  events.create(eventData).then(function (event) {
    res.status(statuses.Created).json(event);
  }).catch(errors.HttpHandler(res));
});

module.exports = router;
