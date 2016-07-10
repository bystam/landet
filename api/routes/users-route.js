'use strict'

const express = require('express');
const router = express.Router();

const users = require('../model/users');
const sessions = require('../model/sessions');

const statuses = require('../util/statuses');
const errors = require('../util/errors');

router.post('/', function(req, res) {
  let username = req.body.username;
  let password = req.body.password;
  let name = req.body.name;

  users.createUser({ username, password, name }).then(function(user) {
    res.json(user);
  }).catch(errors.HttpHandler(res));
});

router.post('/login', function(req, res) {
  let username = req.body.username;
  let password = req.body.password;

  users.userMatchingCredentials(username, password).then(function(user) {
    return sessions.create(user);
  }).then(function(session) {
    res.status(statuses.Created).json({
      token: session.get('token'),
      refresh_token: session.get('refresh_token')
    });
  }).catch(errors.HttpHandler(res));
});

module.exports = router;
