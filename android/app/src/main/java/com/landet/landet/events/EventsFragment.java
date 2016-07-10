package com.landet.landet.events;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityOptionsCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.landet.landet.BaseFragment;
import com.landet.landet.R;
import com.landet.landet.data.Event;

import java.util.List;

import rx.Subscription;
import rx.functions.Action1;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;


public class EventsFragment extends BaseFragment {
    private EventModel mModel;
    private EventsAdapter mEventsAdapter;
    private CompositeSubscription mCompositeSubscription;

    public EventsFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mModel = new EventModel(mBackend);
        mCompositeSubscription = new CompositeSubscription();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_events, container, false);
        final RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        mEventsAdapter = new EventsAdapter(getContext(), new EventsAdapter.EventsListener() {
            @Override
            public void onEventClicked(@NonNull Event event, View view) {
                final Intent intent = new Intent(getContext(), EventDetailsActivity.class);
                intent.putExtra("event", event);
                ActivityOptionsCompat options = ActivityOptionsCompat.
                        makeSceneTransitionAnimation(getActivity(), view, "event_info");
                startActivityForResult(intent, 1, options.toBundle());
            }
        });
        recyclerView.setAdapter(mEventsAdapter);

        FloatingActionButton fab = (FloatingActionButton) view.findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), CreateEventActivity.class);
                startActivity(intent);
            }
        });

        return view;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && resultCode == Activity.RESULT_OK) {
            fetchEvents();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        fetchEvents();
    }

    @Override
    public void onPause() {
        super.onPause();
        mCompositeSubscription.clear();
    }

    private void fetchEvents() {
        final Subscription subscription = mModel.fetchEvents()
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
        mCompositeSubscription.add(subscription);
    }
}