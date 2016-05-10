'use strict'

const Session = require('./entities').Session;
const crypto = require('crypto');

const kSessionTimeoutMilliseconds = 5 * 1000;

function create(user) {
  let token = randomString();
  let refreshToken = randomString();
  let expiration = new Date(Date.now() + kSessionTimeoutMilliseconds);

  return user.related('sessions').create({
    token: token,
    refresh_token: refreshToken,
    expiration_date : expiration
  });
}

function validate(token) {
  return Session.where({ token: token }).fetch().then(function(session) {
    if (!session) { return false; }

    if (session.expiration_date < Date.now()) {
      return session.unset('token').save().then(function() { return false; });
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

function refreshSession(refreshToken) {
  return Session.where({ refresh_token: refreshToken }).fetch().then(function(session) {
    if (!session) { return null; }

    let newToken = randomString();
    return session.set({ token : newToken }).save().then(function(session) {
        return newToken;
    });
  });
}

function randomString() {
  return crypto.randomBytes(64).toString('hex');
}

module.exports = {
  create,
  validate,
  fetchSession,
  refreshSession
}
