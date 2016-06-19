'use strict'

const Topic = require('./entities').Topic;
const Topics = require('./entities').Topics;

const TopicComment = require('./entities').TopicComment;
const TopicComments = require('./entities').TopicComments;
const TopTopicComment = require('./entities').TopTopicComment;

function allTopics() {
  return Topics.forge().fetch({
      withRelated: [
        { 'author': (q) => q.select(['id', 'username', 'name']) },
        // { 'topComment': (q) => q.orderBy('comment_time', 'DESC') },
        // { 'topComment.author': (q) => q.select(['id', 'username', 'name']) },
        // 'topComment'
      ]
    });
}

function create(topicData) {
  return Topic.forge(topicData).save().then(function(topic) {
    // force 'insert' to allow creation of an explicit primary key
    return TopTopicComment.forge({ topic_id : topic.id })
                          .save(null, { method: 'insert' })
                          .yield(topic);
  });
}

function allCommentsForTopicWithId(topicId) {
  return Topic.forge({ id: topicId }).comments()
  .query('orderBy', 'comment_time')
  .fetch({
      withRelated: [
        { 'author': (q) => q.select(['id', 'username', 'name']) }
      ]
    });
}

function createComment(commentData) {
  return TopicComment.forge(commentData).save().then(function(comment) {
    return TopTopicComment.forge({ topic_id : commentData.topic_id })
                          .set('comment_id', comment.id).save()
                          .yield(comment);
  });
}

module.exports = {
  allTopics,
  create,
  allCommentsForTopicWithId,
  createComment
};
