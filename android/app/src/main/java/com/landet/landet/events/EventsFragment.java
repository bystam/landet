package com.landet.landet.events;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.landet.landet.BaseFragment;
import com.landet.landet.R;
import com.landet.landet.api.ApiResponse;
import com.landet.landet.data.Event;

import java.util.List;

import rx.functions.Action1;
import timber.log.Timber;


public class EventsFragment extends BaseFragment {
    private EventModel mModel;

    public EventsFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mModel = new EventModel(mBackend);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_events, container, false);
    }

    @Override
    public void onResume() {
        super.onResume();
        mModel.fetchEvents()
                .subscribe(new Action1<ApiResponse<List<Event>>>() {
                    @Override
                    public void call(ApiResponse<List<Event>> listApiResponse) {
                        Timber.d("success %s", listApiResponse);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "error");
                    }
                });
    }
}