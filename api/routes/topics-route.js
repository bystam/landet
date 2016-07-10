'use strict'

const express = require('express');
const router = express.Router();
const topics = require('../model/topics');

const errors = require('../util/errors');
const statuses = require('../util/statuses');

const comments = require('./topiccomments-route');
router.use('/:topicid/comments', comments);


router.get('/', function(req, res) {
  topics.allTopics().then(function(topics) {
    res.json(topics);
  }).catch(errors.HttpHandler(res));;
});

router.post('/', function(req, res) {
  let topicData = {
    title: req.body.title,
    author_id: req.user.id
  };

  topics.create(topicData).then(function (topic) {
    res.status(statuses.Created).json(topic);
  }).catch(errors.HttpHandler(res));
});

module.exports = router;
