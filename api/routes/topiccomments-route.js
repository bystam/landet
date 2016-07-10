'use strict'

const express = require('express');
const router = express.Router({ mergeParams: true });

const topics = require('../model/topics');
const statuses = require('../util/statuses');
const errors = require('../util/errors');

router.get('/', function(req, res) {
  let topicId = req.params.topicid;
  let pagingData = {
    before: req.query.pageBefore,
    after: req.query.after
  };

  return topics.commentsForTopicId(topicId, pagingData).then(function(comments) {
    res.json(comments);
  }).catch(errors.HttpHandler(res));
});

router.post('/', function(req, res) {
  let commentData = {
    text: req.body.text,
    topic_id: req.params.topicid,
    author_id: req.user.id
  };

  topics.createComment(commentData).then(function(comment) {
    res.status(statuses.Created).json(comment);
  }).catch(errors.HttpHandler(res));
});

module.exports = router;
