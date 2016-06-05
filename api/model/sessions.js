'use strict'

const Session = require('./entities').Session;
const Sessions = require('./entities').Sessions;
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

function fetchSession(token) {
  return Session.where({ token: token }).fetch().then(function(session) {
    if (!session) { return null; }

    const expiration = session.get('expiration_date');
    if (expiration < Date.now()) {
      return session.unset('token').save().then(function() { return null; });
    }

    return session;
  });
}

function refreshSession(refreshToken) {
  return Session.where({ refresh_token: refreshToken }).fetch().then(function(session) {
    if (!session) { return null; }

    let newToken = randomString();
    let expiration = new Date(Date.now() + kSessionTimeoutMilliseconds);
    return session.set({
      token: newToken,
      expiration_date: expiration
    }).save();
  });
}

function randomString() {
  return crypto.randomBytes(64).toString('hex');
}

module.exports = {
  create,
  fetchSession,
  refreshSession
}
