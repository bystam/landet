package com.landet.landet.events;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.landet.landet.BaseActivity;
import com.landet.landet.R;
import com.landet.landet.data.Event;
import com.landet.landet.data.EventComment;
import com.squareup.picasso.Picasso;

import org.joda.time.format.DateTimeFormat;

import java.util.List;

import rx.Subscription;
import rx.functions.Action1;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;

public class EventDetailsActivity extends BaseActivity {
    private EventModel mModel;
    private Event mEvent;
    private EventCommentAdapter mAdapter;
    private CompositeSubscription mCompositeSubscription;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event_details);

        mModel = new EventModel(mBackend);
        mEvent = getIntent().getParcelableExtra("event");
        mCompositeSubscription = new CompositeSubscription();

        setupLayout();

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }

        mAdapter = new EventCommentAdapter(this);
        RecyclerView view = (RecyclerView) findViewById(R.id.comments);
        view.setLayoutManager(new LinearLayoutManager(this));
        view.setAdapter(mAdapter);
    }

    private void setupLayout() {
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        ImageView headerImage = (ImageView) findViewById(R.id.header_image);
        EditText writeComment = (EditText) findViewById(R.id.write_comment);
        TextView title = (TextView) findViewById(R.id.title);
        TextView timePlace = (TextView) findViewById(R.id.time_place);
        TextView author = (TextView) findViewById(R.id.author);
        TextView body = (TextView) findViewById(R.id.body);

        writeComment.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                boolean handled = false;
                if (actionId == EditorInfo.IME_ACTION_SEND) {
                    postComment(mEvent, new EventComment(v.getText().toString()));
                    v.setText("");
                    handled = true;
                    View view = EventDetailsActivity.this.getCurrentFocus();
                    if (view != null) {
                        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
                    }
                }
                return handled;
            }
        });

        toolbar.setTitle(mEvent.getTitle());
        Picasso.with(this).load(mEvent.getLocation().getImageUrl()).into(headerImage);
        title.setText(mEvent.getTitle());
        String day = mEvent.getEventTime().dayOfWeek().getAsText();
        String time = DateTimeFormat.forPattern("HH:mm").print(mEvent.getEventTime());
        String place = mEvent.getLocation().getName();
        timePlace.setText(getString(R.string.day_time_at_place, day, time, place));
        author.setText(getString(R.string.by_author, mEvent.getCreator().getName()));
        body.setText(mEvent.getBody());
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                supportFinishAfterTransition();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onResume() {
        super.onResume();

        fetchCommentsForEvents(mEvent);
    }

    // Call when posting a message or when you want the latest comments for some other reason
    private void fetchCommentsForEvents(@NonNull Event event) {
        final Subscription subscription = mModel.fetchEventComments(event)
                .subscribe(new Action1<List<EventComment>>() {
                    @Override
                    public void call(List<EventComment> eventComments) {
                        Timber.d("comments %s: ", eventComments);
                        mAdapter.setItems(eventComments);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "Failed to load event comments");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    private void postComment(@NonNull final Event event, @NonNull EventComment comment) {
        final Subscription subscription = mModel.postEventComment(event, comment)
                .subscribe(new Action1<EventComment>() {
                    @Override
                    public void call(EventComment comment) {
                        Timber.d("Posted comment: %s", comment.getText());
                        fetchCommentsForEvents(event);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to post comment");
                    }
                });
        mCompositeSubscription.add(subscription);
    }
}
