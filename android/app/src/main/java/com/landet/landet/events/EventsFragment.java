package com.landet.landet.events;

import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.landet.landet.BaseFragment;
import com.landet.landet.R;
import com.landet.landet.data.Event;

import java.util.List;

import rx.functions.Action1;
import timber.log.Timber;


public class EventsFragment extends BaseFragment {
    private EventModel mModel;
    private EventsAdapter mEventsAdapter;

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
        View view = inflater.inflate(R.layout.fragment_events, container, false);
        final RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        mEventsAdapter = new EventsAdapter(getContext());
        recyclerView.setAdapter(mEventsAdapter);
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        mModel.fetchEvents()
                .subscribe(new Action1<List<Event>>() {
                    @Override
                    public void call(List<Event> eventList) {
                        Timber.d("success %s", eventList);
                        mEventsAdapter.setItems(eventList);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "error");
                    }
                });
    }
}