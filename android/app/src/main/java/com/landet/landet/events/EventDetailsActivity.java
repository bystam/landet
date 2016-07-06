package com.landet.landet.events;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.widget.TextView;

import com.landet.landet.BaseActivity;
import com.landet.landet.R;
import com.landet.landet.data.Event;
import com.landet.landet.data.EventComment;

import java.util.List;

import rx.functions.Action1;
import timber.log.Timber;

public class EventDetailsActivity extends BaseActivity {
    private EventModel mModel;
    private Event mEvent;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event_details);

        mModel = new EventModel(mBackend);

        mEvent = getIntent().getParcelableExtra("event");

        TextView title = (TextView) findViewById(R.id.title);
        if (title != null) {
            title.setText(mEvent.getTitle());
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        mModel.fetchEventComments(mEvent)
                .subscribe(new Action1<List<EventComment>>() {
                    @Override
                    public void call(List<EventComment> eventComments) {
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
