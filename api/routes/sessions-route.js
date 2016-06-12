'use strict'

const express = require('express');
const router = express.Router();

const sessions = require('../model/sessions');
const statuses = require('../util/statuses');
const errors = require('../util/errors');

router.get('/', function(req, res, next) {
  let token = req.query.token;
  sessions.fetchSession(token).then(function(session) {
    res.json(session);
  }).catch(errors.HttpHandler(res));
});

router.post('/refresh', function(req, res, next) {
  let refreshToken = req.body.refresh_token;
  sessions.refreshSession(refreshToken).then(function(session) {
    res.status(statuses.Created).json({ token: session.get('token') });
  }).catch(errors.HttpHandler(res));
});

module.exports = router;
