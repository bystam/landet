'use strict'

const express = require('express');
const router = express.Router();

const Day = require('../model/day').Day

router.get('/', function (req, res) {
  Day.fetchAll().then(function(days) {
    res.json(days);
  });
});

/* GET users listing. */
router.post('/', function(req, res) {
  let today = new Date().toISOString().slice(0, 10)
  new Day({ date: today }).save().then(function(day) {
    res.json(day);
  });
});

module.exports = router;
