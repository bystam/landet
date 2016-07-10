package com.landet.landet.events;

import android.support.annotation.NonNull;

import com.landet.landet.api.Backend;
import com.landet.landet.data.Event;
import com.landet.landet.data.EventComment;
import com.landet.landet.utils.ModelUtils;

import java.util.List;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

public class EventModel {
    private Backend mBackend;

    public EventModel(@NonNull Backend backend) {
        mBackend = backend;
    }

    public Observable<List<Event>> fetchEvents() {
        return mBackend.fetchEvents()
                .flatMap(ModelUtils.<List<Event>>mapApiResponseToObservable())
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

    public Observable<Event> createEvent(@NonNull Event event) {
        return mBackend.createEvent(event)
                .flatMap(ModelUtils.<Event>mapApiResponseToObservable())
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

    public Observable<List<EventComment>> fetchEventComments(@NonNull Event event) {
        return mBackend.fetchEventComments(event)
                .flatMap(ModelUtils.<List<EventComment>>mapApiResponseToObservable())
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

    public Observable<EventComment> postEventComment(@NonNull Event event, @NonNull EventComment comment) {
        return mBackend.postEventComment(event, comment)
                .flatMap(ModelUtils.<EventComment>mapApiResponseToObservable())
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }
}
