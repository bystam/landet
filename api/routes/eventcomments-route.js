'use strict'

const express = require('express');
const router = express.Router({ mergeParams: true });

router.get('/', function(req, res) {
  res.json({ message: 'Event comments route: ' + req.params.eventid });
});

module.exports = router;