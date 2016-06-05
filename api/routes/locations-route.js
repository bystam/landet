'use strict'

const express = require('express');
const router = express.Router();

const locations = require('../model/locations');

router.get('/', function(req, res) {
  locations.allLocations().then(function (locations) {
    res.json(locations.toJSON());
  });

});

module.exports = router;
