'use strict'

const express = require('express');
const router = express.Router();

const days = require('../model/days')

router.get('/today', function (req, res) {
  days.fetchToday().then(function(today) {
    res.json(today);
  });
});

module.exports = router;
