package com.landet.landet.topics;

import android.support.annotation.NonNull;

import com.landet.landet.api.ApiResponse;
import com.landet.landet.api.Backend;
import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicComment;
import com.landet.landet.data.TopicCommentListWrapper;

import org.joda.time.DateTime;

import java.util.List;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Func1;
import rx.schedulers.Schedulers;

public class TopicModel {
    private Backend mBackend;
    private TopicCommentCache mCache = new TopicCommentCache();

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

    public Observable<List<TopicComment>> initialLoad(@NonNull Topic topic) {
        if (mCache.hasComments(topic)) {
            return fetchNewerTopicComments(topic);
        } else {
            return fetchOlderTopicComments(topic);
        }
    }

    /**
     * Fetches some more comments and returns an Observable which emits
     * a list with all comments (both known and the new ones)
     */
    public Observable<List<TopicComment>> fetchOlderTopicComments(@NonNull final Topic topic) {
        if (mCache.hasFetchedComments(topic) && !mCache.hasMoreComments(topic)) {
            return Observable.just(mCache.getComments(topic));
        }
        DateTime oldestComment = mCache.getOldestCommentDateTime(topic);

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
                    public Observable<List<TopicComment>> call(TopicCommentListWrapper wrapper) {
                        mCache.insertComments(topic, wrapper.getComments(), wrapper.hasMore());
                        return Observable.just(mCache.getComments(topic));
                    }
                });
    }

    public Observable<List<TopicComment>> fetchNewerTopicComments(@NonNull final Topic topic) {
        DateTime newestComment = mCache.getNewestCommentDateTime(topic);

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
                    public Observable<List<TopicComment>> call(TopicCommentListWrapper wrapper) {
                        mCache.insertComments(topic, wrapper.getComments());
                        return Observable.just(mCache.getComments(topic));
                    }
                });
    }

}
