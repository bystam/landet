package com.landet.landet.topics;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicComment;
import com.landet.landet.data.TopicCommentListWrapper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TopicCommentCache {
    private Map<Topic, TopicCommentListWrapper> cache;

    public TopicCommentCache() {
        cache = new HashMap<>();
    }

    @NonNull
    public List<TopicComment> getComments(@NonNull Topic topic) {
        final TopicCommentListWrapper wrapper = cache.get(topic);
        List<TopicComment> comments = null;
        if (wrapper != null) {
            comments = wrapper.getComments();
        }
        return comments != null ? comments : new ArrayList<TopicComment>();
    }

    public boolean hasComments(@NonNull Topic topic) {
        final TopicCommentListWrapper wrapper = cache.get(topic);
        return wrapper != null && wrapper.getComments() != null && !wrapper.getComments().isEmpty();
    }

    public void insertComments(@NonNull Topic topic, List<TopicComment> comments) {
        insertComments(topic, comments, null);
    }

    public synchronized void insertComments(@NonNull Topic topic, List<TopicComment> comments, @Nullable Boolean hasMoreComments) {
        final TopicCommentListWrapper wrapper = cache.get(topic);
        comments = comments != null ? comments : new ArrayList<TopicComment>();
        List<TopicComment> allComments = comments;
        if (wrapper != null) {
            allComments = wrapper.getComments();
            if (allComments == null || allComments.isEmpty()) {
                allComments = comments;
            } else if (!comments.isEmpty()) {
                if (allComments.get(0).getDateTime().isBefore(comments.get(comments.size()-1).getDateTime())) {
                    allComments.addAll(0, comments);
                } else if (allComments.get(allComments.size()-1).getDateTime().isAfter(comments.get(0).getDateTime())) {
                    allComments.addAll(comments);
                }
            }
        }
        final boolean more = hasMoreComments != null ? hasMoreComments : hasMoreComments(topic);
        cache.put(topic, new TopicCommentListWrapper(allComments, more));
    }

    public boolean hasMoreComments(@NonNull Topic topic) {
        final TopicCommentListWrapper wrapper = cache.get(topic);
        return wrapper != null && wrapper.hasMore();
    }
}
