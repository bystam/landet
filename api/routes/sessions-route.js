'use strict'

const express = require('express');
const router = express.Router();

const sessions = require('../model/sessions');

/* GET users listing. */
router.get('/', function(req, res, next) {
  let token = req.query.token;
  sessions.fetchSession(token).then(function(session) {
    res.json(session);
  });
});

module.exports = router;
