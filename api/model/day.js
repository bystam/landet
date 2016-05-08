
const bookshelf = require('./bookshelf').bookshelf;

const Day = bookshelf.Model.extend({
  tableName: 'days'
});

module.exports = {
  Day
}
