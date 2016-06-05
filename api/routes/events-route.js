'use strict'

const express = require('express');
const router = express.Router();

const comments = require('./eventcomments-route');
router.use('/:eventid/comments', comments);

router.get('/', function(req, res) {
  res.json({ message: 'Events route' });
});

module.exports = router;
