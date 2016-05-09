'use strict'

const Session = require('./entities').Session;
const crypto = require('crypto');

const kSessionTimeoutMilliseconds = 60 * 1000;

function create(user) {
  let token = crypto.randomBytes(64).toString('hex');
  let expiration = new Date(Date.now() + kSessionTimeoutMilliseconds);

  return user.related('sessions').create({
    token: token,
    expiration_date : expiration
  });
}

function validate(token) {
  return Session.where({ token: token }).fetch().then(function(session) {
    if (!session) { return false; }

    if (session.expiration_date < Date.now()) {
      return session.destroy().then(function() { return false; });
    }

    return session.token === token;
  });
}

function fetchSession(token) {
  return Session.where({ token: token }).fetch().then(function(session) {
    if (!session) { return null; }

    if (session.get('expiration_date') < Date.now()) {
      return session.destroy().then(function() { return null; });
    }

    return session;
  });
}

module.exports = {
  create,
  validate,
  fetchSession
}
