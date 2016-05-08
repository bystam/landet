'use strict'

const Post = require('./entities').Post;

function createPost(text, day) {
  let postData = { text: text };
  return day.related('posts').create(postData)
}

module.exports = {
  createPost
}
