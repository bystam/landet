'use strict'

const sessions = require('../model/sessions');

const errors = require('../util/errors');

function authenticate(req, res, next) {
  let token = req.get('Authorization') || '';
  token = token.replace('Basic ', '');

  sessions.userWithSessionToken(token).then(function (user) {
    req.user = user;
    next();
  }).catch(errors.HttpHandler(res));
}

module.exports = {
  authenticate
};
