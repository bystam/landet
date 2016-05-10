'use strict'

const express = require('express');
const router = express.Router();

const sessions = require('../model/sessions');

router.get('/', function(req, res, next) {
  let token = req.query.token;
  sessions.fetchSession(token).then(function(session) {
    res.json(session);
  });
});

router.post('/refresh', function(req, res, next) {
  let refreshToken = req.body.refresh_token;
  sessions.refreshSession(refreshToken).then(function(newToken) {
    res.status(201).json({ token: newToken });
  });
});

module.exports = router;
