'use strict'

function LandetError(message) {
  this.name = 'LandetError';
  this.message = message || 'Default Message';
  this.stack = (new Error()).stack;
}
LandetError.prototype = Object.create(Error.prototype);
LandetError.prototype.constructor = LandetError;

function HttpHandler(res) {
  return function(error) {
    if (error instanceof LandetError) {
      res.status(error.httpStatus).json(error.asJSON);
    } else {
      throw error;
    }
  }
}

const BadRequestCode = 400;
const UnauthorizedCode = 401;
const ForbiddenCode = 403;
const NotFoundCode = 404;

function error(httpStatus, apiCode, message) {
  return function () {
    let error = new LandetError(message);
    error.httpStatus = httpStatus;
    error.asJSON = {
      landet_error: {
        status: httpStatus,
        api_code: apiCode,
        message: message
      }
    }

    return error;
  }
}

const User = {
  UsernameTaken: error(ForbiddenCode, "LE-101", "Username already exists"),
  WrongCredentials: error(ForbiddenCode, "LE-102", "Wrong username or password.")
};


const Unauthorized = {
  InvalidToken: error(UnauthorizedCode, "LE-201", "Invalid auth token"),
  InvalidRefreshToken: error(UnauthorizedCode, "LE-202", "Invalid refresh token")
};

const Topic = {
  MaxOneCommentPagingAllowed: error(BadRequestCode, "LE-401",
      "Can page using either after or beforePage but not both"),

}

module.exports = {
  LandetError,
  HttpHandler,

  User,
  Unauthorized,
  Topic
};
