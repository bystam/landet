
exports.up = function(knex, Promise) {

  return Promise.all([

        knex.schema.createTable('users', function(table) {
            table.increments('id').primary();
            table.string('username').unique().notNullable();
            table.string('hashedpw').notNullable();
            table.string('name').notNullable();
            table.timestamps();
        }),

        knex.schema.createTable('sessions', function(table) {
          table.increments('id').primary();
          table.string('token').notNullable().index();
          table.string('refresh_token').notNullable();
          table.dateTime('expiration_date').notNullable();

          table.integer('user_id')
               .references('id')
               .inTable('users')
               .notNullable();
        }),

        knex.schema.createTable('locations', function(table) {
          table.increments('id').primary();
          table.string('enum_id').unique().notNullable();
          table.string('name').notNullable();
          table.string('image_url').notNullable();
        }),

        knex.schema.createTable('events', function(table) {
            table.increments('id').primary();
            table.string('title').notNullable();
            table.string('body').notNullable();
            table.dateTime('event_time').notNullable();

            table.integer('creator_id')
                 .references('id')
                 .inTable('users')
                 .notNullable();
            table.integer('location_id')
                 .references('id')
                 .inTable('locations')
                 .notNullable();
        }),

        knex.schema.createTable('event_comments', function(table) {
          table.increments('id').primary();
          table.string('text').notNullable();
          table.timestamp('comment_time');

          table.integer('author_id')
               .references('id')
               .inTable('users')
               .notNullable();
          table.integer('event_id')
               .references('id')
               .inTable('events')
               .notNullable();
        }),

        knex.schema.createTable('topics', function(table) {
            table.increments('id').primary();
            table.string('title').notNullable();
            table.timestamps();

            table.integer('author_id')
                 .references('id')
                 .inTable('users')
                 .notNullable();
        }),

        knex.schema.createTable('topic_comments', function(table) {
          table.increments('id').primary();
          table.string('text').notNullable();
          table.timestamp('comment_time').notNullable();

          table.integer('author_id')
               .references('id')
               .inTable('users')
               .notNullable();
          table.integer('topic_id')
               .references('id')
               .inTable('topics')
               .notNullable();
        }),

    ]).then(function() {
      // create the default locations
      return knex('locations').insert(require('../locations').locations);
    });
};

exports.down = function(knex, Promise) {
  return Promise.all([
    knex.schema.dropTable('sessions'),
    knex.schema.dropTable('event_comments'),
    knex.schema.dropTable('events'),
    knex.schema.dropTable('topic_comments'),
    knex.schema.dropTable('topics'),
    knex.schema.dropTable('locations'),
    knex.schema.dropTable('users'),
  ]);
};
