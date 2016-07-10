package com.landet.landet.locations;

import android.support.annotation.NonNull;

import com.landet.landet.api.Backend;
import com.landet.landet.data.Location;
import com.landet.landet.data.MapContent;
import com.landet.landet.utils.ModelUtils;

import java.util.ArrayList;
import java.util.List;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

public class LocationModel {
    private Backend mBackend;
    private static List<Location> mCache = new ArrayList<>();

    public LocationModel(@NonNull Backend backend) {
        mBackend = backend;
    }

    public Observable<List<Location>> fetchLocations() {
        Observable<List<Location>> networked = mBackend.fetchLocations()
                .flatMap(ModelUtils.<List<Location>>mapApiResponseToObservable())
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());

        return (mCache.isEmpty()) ?
                networked :
                Observable.just(mCache);
    }

    public Observable<MapContent> fetchMapContent() {
        return mBackend.fetchMapContent()
                .flatMap(ModelUtils.<MapContent>mapApiResponseToObservable())
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }
}
