package com.landet.landet.events;

import android.support.annotation.NonNull;

import com.landet.landet.api.ApiResponse;
import com.landet.landet.api.Backend;
import com.landet.landet.data.Event;
import com.landet.landet.data.EventComment;

import java.util.List;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Func1;
import rx.schedulers.Schedulers;

public class EventModel {
    private Backend mBackend;

    public EventModel(@NonNull Backend backend) {
        mBackend = backend;
    }

    public Observable<List<Event>> fetchEvents() {
        return mBackend.fetchEvents()
                .flatMap(new Func1<ApiResponse<List<Event>>, Observable<List<Event>>>() {
                    @Override
                    public Observable<List<Event>> call(ApiResponse<List<Event>> apiResponse) {
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

    public Observable<List<EventComment>> fetchEventComments(@NonNull Event event) {
        return mBackend.fetchEventComments(event)
                .flatMap(new Func1<ApiResponse<List<EventComment>>, Observable<List<EventComment>>>() {
                    @Override
                    public Observable<List<EventComment>> call(ApiResponse<List<EventComment>> apiResponse) {
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
