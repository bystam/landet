package com.landet.landet.events;

import android.support.annotation.NonNull;

import com.landet.landet.api.ApiResponse;
import com.landet.landet.api.Backend;
import com.landet.landet.data.Event;

import java.util.List;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

public class EventModel {
    private Backend mBackend;

    public EventModel(@NonNull Backend backend) {
        mBackend = backend;
    }

    public Observable<ApiResponse<List<Event>>> fetchEvents() {
        return mBackend.fetchEvents()
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }
}
