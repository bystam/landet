'use strict'

const Day = require('./entities').Day;

function fetchToday() {
  return Day.where({ date: todayString() }).fetch().then(function(today) {
    if (today) return today;
    else return createToday();
  });
}

function createToday() {
  console.log('--- today create attempt ---')
  return new Day({ date: todayString() }).save();
}

function todayString() {
  return new Date().toISOString().slice(0, 10)
}

module.exports = {
  fetchToday
}
