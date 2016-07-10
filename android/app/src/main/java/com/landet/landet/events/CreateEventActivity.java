package com.landet.landet.events;

import android.os.Bundle;
import android.support.annotation.Nullable;

import com.landet.landet.BaseActivity;
import com.landet.landet.R;
import com.landet.landet.data.Location;
import com.landet.landet.locations.LocationModel;

import java.util.List;

import rx.Subscription;
import rx.functions.Action1;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;

public class CreateEventActivity extends BaseActivity {
    private LocationModel mLocationModel;
    private CompositeSubscription mCompositeSubscription;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_event);
        mCompositeSubscription = new CompositeSubscription();
        mLocationModel = new LocationModel(mBackend);
        fetchLocations();
    }

    private void fetchLocations() {
        final Subscription subscription = mLocationModel.fetchLocations()
                .subscribe(new Action1<List<Location>>() {
                    @Override
                    public void call(List<Location> locations) {
                        Timber.d("Fetched locations: %s", locations);
                        //TODO Populate list of locations
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to fetch locations");
                    }
                });
        mCompositeSubscription.add(subscription);
    }
}
