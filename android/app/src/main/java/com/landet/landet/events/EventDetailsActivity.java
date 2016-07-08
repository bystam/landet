package com.landet.landet.events;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.widget.TextView;

import com.landet.landet.BaseActivity;
import com.landet.landet.R;
import com.landet.landet.data.Event;
import com.landet.landet.data.EventComment;

import org.joda.time.format.DateTimeFormat;

import java.util.List;

import rx.functions.Action1;
import timber.log.Timber;

public class EventDetailsActivity extends BaseActivity {
    private EventModel mModel;
    private Event mEvent;
    private EventCommentsAdapter mAdapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event_details);

        mModel = new EventModel(mBackend);
        mEvent = getIntent().getParcelableExtra("event");
        setupLayout();

        mAdapter = new EventCommentsAdapter(this);
        RecyclerView view = (RecyclerView) findViewById(R.id.comments);
        view.setLayoutManager(new LinearLayoutManager(this));
        view.setAdapter(mAdapter);
    }

    private void setupLayout() {
        // ImageView headerImage = (ImageView) findViewById(R.id.header_image); // TODO: get from location.
        TextView eventTitle = (TextView) findViewById(R.id.event_title);
        TextView title = (TextView) findViewById(R.id.title);
        TextView timePlace = (TextView) findViewById(R.id.time_place);
        TextView author = (TextView) findViewById(R.id.author);
        TextView body = (TextView) findViewById(R.id.body);

        eventTitle.setText(mEvent.getTitle());
        title.setText(mEvent.getTitle());
        String day = mEvent.getEventTime().dayOfWeek().getAsText();
        String time = DateTimeFormat.forPattern("HH:mm").print(mEvent.getEventTime());
        String place = mEvent.getLocation().getName();
        timePlace.setText(getString(R.string.day_time_at_place, day, time, place));
        author.setText(getString(R.string.by_author, mEvent.getCreator().getName()));
        body.setText(mEvent.getBody());
    }

    @Override
    protected void onResume() {
        super.onResume();

        mModel.fetchEventComments(mEvent)
                .subscribe(new Action1<List<EventComment>>() {
                    @Override
                    public void call(List<EventComment> eventComments) {
                        mAdapter.setItems(eventComments);
                        Timber.d("Comments: %s", eventComments);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "Comments failed to load");
                    }
                });
    }
}
