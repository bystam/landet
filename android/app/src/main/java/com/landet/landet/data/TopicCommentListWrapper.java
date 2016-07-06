package com.landet.landet.data;

import java.util.List;

public class TopicCommentListWrapper {
    private List<TopicComment> comments;
    private boolean hasMore;

    public List<TopicComment> getComments() {
        return comments;
    }

    public boolean hasMore() {
        return hasMore;
    }
}
