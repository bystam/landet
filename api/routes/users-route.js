'use strict'

const express = require('express');
const router = express.Router();

const users = require('../model/users');
const sessions = require('../model/sessions');

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('respond with a resource');
});

router.post('/create', function(req, res) {
  let username = req.body.username;
  let password = req.body.password;

  users.createUser(username, password).then(function(user) {
    res.json(user);
  });
});

router.post('/login', function(req, res) {
  let username = req.body.username;
  let password = req.body.password;

  users.userMatchingCredentials(username, password).then(function(user) {
    return sessions.create(user);
  }).then(function(session) {
    res.json(session);
  });
});

module.exports = router;
