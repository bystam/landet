'use strict'

const sessions = require('../model/sessions');

const kUnauthorized = {
  status: 401,
  message: '401: Unauthorized'
};

function authenticate(req, res, next) {
  let token = req.get('Authorization');
  token = token.replace('Basic ', '');
  if (token.length === 0) {
    return res.status(401).json(kUnauthorized);
  }

  sessions.userWithSessionToken(token).then(function (user) {
    if (!user) {
      return res.status(401).json(kUnauthorized);
    }

    req.user = user;
    next();
  });
}

module.exports = {
  authenticate
};
