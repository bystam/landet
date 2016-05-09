'use strict'

const User = require('./entities').User;
const bcrypt = require('bcrypt');

function createUser(username, password) {
  return hash(password).then(function(hashed) {
    return new User({
      username: username,
      hashedpw: hashed
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
    if (!user) { return null; }

    candidate = user;
    return compare(password, user.get('hashedpw'));
  }).then(function(passwordMatch) {
    if (passwordMatch) { return candidate; }
    else { return null; }
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
