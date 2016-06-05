'use strict'

const express = require('express');
const router = express.Router();

const sessions = require('../model/sessions');

function logError(e) {
  console.log(e);
}

router.get('/', function(req, res, next) {
  let token = req.query.token;
  sessions.fetchSession(token).then(function(session) {
    res.json(session);
  }).catch(logError);
});

router.post('/refresh', function(req, res, next) {
  let refreshToken = req.body.refresh_token;
  sessions.refreshSession(refreshToken).then(function(session) {
    res.status(201).json(session);
  }).catch(logError);
});

module.exports = router;
