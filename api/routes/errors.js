'use strict'

function httpError(code, message) {
  let error = new Error(message);
  error.status = code;
  return error;
}

module.exports = {
  httpError
}
