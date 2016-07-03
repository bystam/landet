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

  const kPageSize = 10

  let query = function(q) {
    q.orderBy('comment_time', 'DESC')

    if (pagingData.before) {
      q.where('comment_time', '<', pagingData.before);
      q.limit(kPageSize);
    } else if (pagingData.after) {
      q.where('comment_time', '>', pagingData.after);
    } else {
      q.limit(kPageSize);
    }
  }

  return Topic.forge({ id: topicId }).comments()
              .query(query)
              .fetch({
                  withRelated: [ 'author' ]
                }).then(function(comments) {
                  return {
                    comments: comments,
                    hasMore: comments.length == kPageSize
                  }
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
