'use strict'

const User = require('./entities').User;
const Users = require('./entities').Users;
const bcrypt = require('bcrypt');

const errors = require('../util/errors');

function createUser(user) {
  return User.forge({ username : user.username }).fetch().then(existing => {
    if (existing) { throw errors.User.UsernameTaken(); }

    return hash(user.password);
  }).then(hashed => {
    return User.forge({
      username: user.username,
      hashedpw: hashed,
      name: user.name
    }).save();
  });
}

function hash(string) {
  return new Promise(function(fulfill, reject) {
    bcrypt.hash(string, 10, function(err, hashed) {
      if (err) { reject(err); }
      else { fulfill(hashed); }
    });
  });
}

function userMatchingCredentials(username, password) {
  let candidate = null;

  return User.where({ username: username }).fetch().then(function(user) {
    if (!user) { throw errors.User.WrongCredentials(); }

    candidate = user;
    return compare(password, user.get('hashedpw'));
  }).then(function(passwordMatch) {
    if (passwordMatch) { return candidate; }
    else { throw errors.User.WrongCredentials(); }
  });
}

function compare(string, hashed) {
  return new Promise(function(fulfill, reject) {
    bcrypt.compare(string, hashed, function(err, equal) {
      if (err) { reject(err); }
      else { fulfill(equal); }
    });
  });
}

module.exports = {
  createUser,
  userMatchingCredentials
}
