'use strict'

const Location = require('./entities').Location;
const Locations = require('./entities').Locations;

function allLocations() {
  return Locations.forge().fetch();
}

module.exports = {
  allLocations
};
