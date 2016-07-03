'use strict'

const Topic = require('./entities').Topic;
const Topics = require('./entities').Topics;

const TopicComment = require('./entities').TopicComment;
const TopicComments = require('./entities').TopicComments;

const errors = require('../util/errors');

function allTopics() {
  return Topics.forge().fetch({
    columns: ['id', 'title', 'author_id'],
    withRelated: [ 'author' ]
  });
}

function create(topicData) {
  return Topic.forge(topicData).save();
}

function commentsForTopicId(topicId, pagingData) {
  if (pagingData.before && pagingData.after) {
    throw errors.Topic.MaxOneCommentPagingAllowed();
  }

  let query = function(q) {
    q.orderBy('comment_time', 'DESC')

    if (pagingData.before) {
      q.where('comment_time', '<', pagingData.before);
      q.limit(10);
    } else if (pagingData.after) {
      q.where('comment_time', '>', pagingData.after);
    } else {
      q.limit(10);
    }
  }

  return Topic.forge({ id: topicId }).comments()
              .query(query)
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
  commentsForTopicId,
  createComment
};
