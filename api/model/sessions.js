'use strict'

const Session = require('./entities').Session;
const Sessions = require('./entities').Sessions;
const crypto = require('crypto');
const errors = require('../util/errors');

//const kSessionTimeoutMilliseconds = 5 * 1000;
const kSessionTimeoutMilliseconds = 2 * 60 * 60 * 1000;

function create(user) {
  let token = randomString();
  let refreshToken = randomString();
  let expiration = new Date(Date.now() + kSessionTimeoutMilliseconds);

  return user.sessions().create({
    token: token,
    refresh_token: refreshToken,
    expiration_date : expiration
  });
}

function userWithSessionToken(token) {
  return Session.where({ token: token }).fetch().then(function(session) {
    if (!session) { throw errors.Unauthorized.TokenInvalid(); }

    const expiration = session.get('expiration_date');
    if (expiration < Date.now()) {
      throw errors.Unauthorized.TokenExpired();
    }

    return session.user().fetch();
  });
}

function fetchSession(token) {
  return Session.where({ token: token }).fetch().then(function(session) {
    if (!session) { throw errors.Unauthorized.TokenInvalid(); }

    const expiration = session.get('expiration_date');
    if (expiration < Date.now()) {
      throw errors.Unauthorized.TokenExpired();
    }

    return session;
  });
}

function refreshSession(refreshToken) {
  return Session.where({ refresh_token: refreshToken }).fetch().then(function(session) {
    if (!session) { throw errors.Unauthorized.InvalidRefreshToken(); }

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
  userWithSessionToken,
  fetchSession,
  refreshSession
}
