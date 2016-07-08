package com.landet.landet.topics;

import android.support.annotation.NonNull;

import com.landet.landet.api.ApiResponse;
import com.landet.landet.api.Backend;
import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicComment;
import com.landet.landet.data.TopicCommentListWrapper;

import org.joda.time.DateTime;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Func1;
import rx.schedulers.Schedulers;

public class TopicModel {
    private Backend mBackend;
    private Map<Topic, TopicCommentListWrapper> mCommentCache = new HashMap<>();

    public TopicModel(@NonNull Backend backend) {
        mBackend = backend;
    }

    public Observable<List<Topic>> fetchTopics() {
        return mBackend.fetchTopics()
                .flatMap(new Func1<ApiResponse<List<Topic>>, Observable<List<Topic>>>() {
                    @Override
                    public Observable<List<Topic>> call(ApiResponse<List<Topic>> apiResponse) {
                        if (apiResponse.isSuccessful()) {
                            return Observable.just(apiResponse.getBody());
                        } else {
                            return Observable.error(apiResponse.getError());
                        }
                    }
                })
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

    /**
     * Fetches some more comments and returns an Observable which emits
     * a list with all comments (both known and the new ones)
     */
    public Observable<List<TopicComment>> fetchOlderTopicComments(@NonNull final Topic topic) {
        final TopicCommentListWrapper topicComments = mCommentCache.get(topic);
        if (topicComments != null && topicComments.getComments() != null && !topicComments.hasMore()) {
            return Observable.just(topicComments.getComments());
        }
        DateTime oldestComment = topicComments != null ?
                topicComments.getComments().get(topicComments.getComments().size()-1).getDateTime() :
                DateTime.now();

        return mBackend.fetchTopicComments(topic, oldestComment, null)
                .flatMap(new Func1<ApiResponse<TopicCommentListWrapper>, Observable<TopicCommentListWrapper>>() {
                    @Override
                    public Observable<TopicCommentListWrapper> call(ApiResponse<TopicCommentListWrapper> apiResponse) {
                        if (apiResponse.isSuccessful()) {
                            return Observable.just(apiResponse.getBody());
                        } else {
                            return Observable.error(apiResponse.getError());
                        }
                    }
                })
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .flatMap(new Func1<TopicCommentListWrapper, Observable<List<TopicComment>>>() {
                    @Override
                    public Observable<List<TopicComment>> call(TopicCommentListWrapper topicCommentListWrapper) {
                        final TopicCommentListWrapper cache = mCommentCache.get(topic);
                        if (cache != null && cache.getComments() != null) {
                            topicCommentListWrapper.getComments().addAll(0, cache.getComments());
                        }
                        mCommentCache.put(topic, topicCommentListWrapper);
                        return Observable.just(topicCommentListWrapper.getComments());
                    }
                });
    }

    public Observable<List<TopicComment>> fetchNewerTopicComments(@NonNull final Topic topic) {
        final TopicCommentListWrapper topicComments = mCommentCache.get(topic);
        DateTime newestComment = topicComments != null ?
                topicComments.getComments().get(0).getDateTime() : //Load all comments that are newer than the newest known comment
                null; //Load initial 10 comments

        return mBackend.fetchTopicComments(topic, null, newestComment)
                .flatMap(new Func1<ApiResponse<TopicCommentListWrapper>, Observable<TopicCommentListWrapper>>() {
                    @Override
                    public Observable<TopicCommentListWrapper> call(ApiResponse<TopicCommentListWrapper> apiResponse) {
                        if (apiResponse.isSuccessful()) {
                            return Observable.just(apiResponse.getBody());
                        } else {
                            return Observable.error(apiResponse.getError());
                        }
                    }
                })
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .flatMap(new Func1<TopicCommentListWrapper, Observable<List<TopicComment>>>() {
                    @Override
                    public Observable<List<TopicComment>> call(TopicCommentListWrapper topicCommentListWrapper) {
                        final TopicCommentListWrapper cache = mCommentCache.get(topic);
                        if (cache != null && cache.getComments() != null) {
                            topicCommentListWrapper.getComments().addAll(cache.getComments());
                        }
                        mCommentCache.put(topic, topicCommentListWrapper);
                        return Observable.just(topicCommentListWrapper.getComments());
                    }
                });
    }

    public Observable<List<TopicComment>> fetchTopicComments(@NonNull final Topic topic) {
        return mBackend.fetchTopicComments(topic, null, null)
                .flatMap(new Func1<ApiResponse<TopicCommentListWrapper>, Observable<TopicCommentListWrapper>>() {
                    @Override
                    public Observable<TopicCommentListWrapper> call(ApiResponse<TopicCommentListWrapper> apiResponse) {
                        if (apiResponse.isSuccessful()) {
                            return Observable.just(apiResponse.getBody());
                        } else {
                            return Observable.error(apiResponse.getError());
                        }
                    }
                })
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .map(new Func1<TopicCommentListWrapper, List<TopicComment>>() {
                    @Override
                    public List<TopicComment> call(TopicCommentListWrapper topicCommentListWrapper) {
                        mCommentCache.put(topic, topicCommentListWrapper);
                        return topicCommentListWrapper.getComments();
                    }
                });
    }
}
