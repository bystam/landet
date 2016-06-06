'use strict'

const express = require('express');
const router = express.Router();

const users = require('../model/users');
const sessions = require('../model/sessions');

const errors = require('../util/errors');

router.post('/create', function(req, res) {
  let username = req.body.username;
  let password = req.body.password;
  let name = req.body.name;

  users.createUser({ username, password, name }).then(function(user) {
    res.json(user);
  }).catch(function(error) {
    if (error instanceof errors.LandetError) {
      res.status(error.httpStatus).json(error.asJSON);
    } else {
      throw error;
    }
  });
});

router.post('/login', function(req, res) {
  let username = req.body.username;
  let password = req.body.password;

  users.userMatchingCredentials(username, password).then(function(user) {
    return sessions.create(user);
  }).then(function(session) {
    res.json(session.omit('expiration_date'));
  }).catch(error => {
    if (error instanceof errors.LandetError) {
      res.status(error.httpStatus).json(error.asJSON);
    } else {
      throw error;
    }
  });
});

module.exports = router;
