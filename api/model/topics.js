'use strict'

const Topic = require('./entities').Topic;
const Topics = require('./entities').Topics;

const TopicComment = require('./entities').TopicComment;
const TopicComments = require('./entities').TopicComments;

function allTopics() {
  return Topics.forge().fetch({
    columns: ['id', 'title', 'author_id'],
    withRelated: [ 'author' ]
  });
}

function create(topicData) {
  return Topic.forge(topicData).save();
}

function allCommentsForTopicWithId(topicId) {
  return Topic.forge({ id: topicId }).comments()
              .query('orderBy', '-comment_time')
              .fetch({
                  withRelated: [ 'author' ]
                });
}

function createComment(commentData) {
  return TopicComment.forge(commentData).save();
}

module.exports = {
  allTopics,
  create,
  allCommentsForTopicWithId,
  createComment
};
