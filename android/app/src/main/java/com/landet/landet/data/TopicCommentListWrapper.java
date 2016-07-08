package com.landet.landet.data;

import java.util.List;

public class TopicCommentListWrapper {
    private List<TopicComment> comments;
    private boolean hasMore;

    public TopicCommentListWrapper() {}

    public TopicCommentListWrapper(List<TopicComment> comments, boolean hasMore) {
        this.comments = comments;
        this.hasMore = hasMore;
    }

    public List<TopicComment> getComments() {
        return comments;
    }

    public boolean hasMore() {
        return hasMore;
    }
}
