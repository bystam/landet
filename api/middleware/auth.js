
const sessions = require('../model/sessions');

function authenticate(req, res, next) {
  console.log('authentication required');
  next();
}

module.exports = {
  authenticate
};
