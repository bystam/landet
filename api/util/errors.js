'use strict'

function LandetError(message) {
  this.name = 'LandetError';
  this.message = message || 'Default Message';
  this.stack = (new Error()).stack;
}
LandetError.prototype = Object.create(Error.prototype);
LandetError.prototype.constructor = LandetError;

const BadRequestCode = 400;
const UnauthorizedCode = 401;
const ForbiddenCode = 403;
const NotFoundCode = 404;

function error(httpStatus, apiCode, message) {
  return function () {
    let error = new LandetError(message);
    error.httpStatus = httpStatus;
    error.asJSON = {
      status: httpStatus,
      api_code: apiCode,
      message: message
    }

    return error;
  }
}

const User = {
  UsernameTaken: error(ForbiddenCode, "LE-101", "Username already exists"),
  WrongCredentials: error(ForbiddenCode, "LE-102", "Wrong username or password.")
};

const Unauthorized = error(UnauthorizedCode, "LE-103", "Unauthorized")


module.exports = {
  LandetError,
  User,
  Unauthorized
}
