
exports.up = function(knex, Promise) {

  return Promise.all([

        knex.schema.createTable('users', function(table) {
            table.increments('uid').primary();
            table.string('username');
            table.string('password');
            table.string('name');
            table.timestamps();
        }),

        knex.schema.createTable('sessions', function(table) {
          table.increments('id').primary();
          table.string('token');
          table.string('refresh_token');
          table.dateTime('expiration_date');

          table.integer('user_id')
               .references('uid')
               .inTable('users');
        }),

        knex.schema.createTable('locations', function(table) {
          table.increments('id').primary();
          table.string('enum_id').unique();
          table.string('name');
          table.string('image_url');
        }),

        knex.schema.createTable('events', function(table) {
            table.increments('id').primary();
            table.string('title');
            table.string('body');
            table.dateTime('event_time');

            table.integer('creator_id')
                 .references('uid')
                 .inTable('users');
            table.integer('location_id')
                 .references('id')
                 .inTable('locations');
        }),

        knex.schema.createTable('event_comments', function(table) {
          table.increments('id').primary();
          table.string('text');
          table.dateTime('comment_time');

          table.integer('author_id')
               .references('uid')
               .inTable('users');
          table.integer('event_id')
               .references('id')
               .inTable('events');
        })
    ]);
};

exports.down = function(knex, Promise) {
  return Promise.all([
    knex.schema.dropTable('sessions'),
    knex.schema.dropTable('events'),
    knex.schema.dropTable('locations'),
    knex.schema.dropTable('users'),
  ]);
};
