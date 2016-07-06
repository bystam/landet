package com.landet.landet.topics;

import android.support.annotation.NonNull;

import com.landet.landet.api.ApiResponse;
import com.landet.landet.api.Backend;
import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicCommentListWrapper;

import java.util.List;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Func1;
import rx.schedulers.Schedulers;

public class TopicModel {
    private Backend mBackend;

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

    public Observable<TopicCommentListWrapper> fetchTopicComments(@NonNull Topic topic) {
        return mBackend.fetchTopicComments(topic)
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
                .observeOn(AndroidSchedulers.mainThread());
    }
}
