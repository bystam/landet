'use strict'

const express = require('express');
const router = express.Router();

const posts = require('../model/posts')
const days = require('../model/days')

router.post('/', function (req, res) {
  let text = req.body.text;

  days.fetchToday().then(function(today) {
    posts.createPost(text, today).then(function(post) {
      res.json(post);
    });
  });
});

module.exports = router;
