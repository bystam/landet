package com.landet.landet.topics;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import com.landet.landet.BaseActivity;
import com.landet.landet.R;
import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicComment;

import java.util.List;

import rx.Subscription;
import rx.functions.Action1;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;

/**
 * Created by shayan on 10/07/16.
 */
public class TopicDetailsActivity extends BaseActivity {
    private TopicModel mModel;
    private Topic mTopic;
    private TopicCommentAdapter mAdapter;
    private CompositeSubscription mCompositeSubscription;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_topic_details);

        mModel = new TopicModel(mBackend);
        mTopic = getIntent().getParcelableExtra("topic");

        mCompositeSubscription = new CompositeSubscription();

        TextView title = (TextView) findViewById(R.id.title); // TODO: add a onclicklistener to send the user back to the topics fragment.
        TextView author = (TextView) findViewById(R.id.author);
        title.setText(mTopic.getTitle());
        author.setText(getString(R.string.by_author, mTopic.getAuthor().getName()));

        EditText writeComment = (EditText) findViewById(R.id.write_comment);
        writeComment.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                boolean handled = false;
                if (actionId == EditorInfo.IME_ACTION_SEND) {
                    postComment(mTopic, new TopicComment(v.getText().toString()));
                    v.setText("");
                    handled = true;
                    View view = TopicDetailsActivity.this.getCurrentFocus();
                    if (view != null) {
                        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
                    }
                }
                return handled;
            }
        });


        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }

        mAdapter = new TopicCommentAdapter(this);
        RecyclerView view = (RecyclerView) findViewById(R.id.comments);
        view.setLayoutManager(new LinearLayoutManager(this));
        view.addOnScrollListener(new RecyclerView.OnScrollListener() {
            private int previousTotal = 0;
            private boolean loading = true;
            private final int MAX_VISIBLE = 10;
            int firstVisibleItem, visibleItemCount, totalItemCount;
            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                if (dy > 0) {
                    LinearLayoutManager layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
                    visibleItemCount = layoutManager.getChildCount();
                    totalItemCount = layoutManager.getItemCount();
                    firstVisibleItem = layoutManager.findFirstVisibleItemPosition();

                    if (loading) {
                        if (totalItemCount > previousTotal) {
                            loading = false;
                            previousTotal = totalItemCount;
                        }
                    }
                    if (!loading && (totalItemCount - visibleItemCount)
                            <= (firstVisibleItem + MAX_VISIBLE)) {
                        final Subscription subscription = mModel.fetchOlderTopicComments(mTopic)
                                .subscribe(new Action1<List<TopicComment>>() {
                                    @Override
                                    public void call(List<TopicComment> topicComments) {
                                        Timber.d("comments %s: ", topicComments);
                                        mAdapter.setItems(topicComments);
                                    }
                                }, new Action1<Throwable>() {
                                    @Override
                                    public void call(Throwable throwable) {
                                        Timber.d(throwable, "Failed to load topic comments");
                                    }
                                });
                        mCompositeSubscription.add(subscription);
                        loading = true;
                    }
                }
            }
        });
        view.setAdapter(mAdapter);
    }

    @Override
    protected void onResume() {
        super.onResume();

        final Subscription subscription = mModel.initialLoad(mTopic)
                .subscribe(new Action1<List<TopicComment>>() {
                    @Override
                    public void call(List<TopicComment> topicComments) {
                        mAdapter.setItems(topicComments);
                        Timber.d("Comments %s", topicComments);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to fetch comments");
                    }
                });
        mCompositeSubscription.add(subscription);
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

    // Call when posting a message or when you want the latest comments for some other reason
    private void fetchNewerCommentsForTopic(@NonNull Topic topic) {
        final Subscription subscription = mModel.fetchNewerTopicComments(topic)
                .subscribe(new Action1<List<TopicComment>>() {
                    @Override
                    public void call(List<TopicComment> topicComments) {
                        Timber.d("comments %s: ", topicComments);
                        mAdapter.setItems(topicComments);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "Failed to load topic comments");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    // Call when swiping to the bottom of a list of comments to load older ones
    private void fetchOlderCommentsForTopic(@NonNull Topic topic) {
        final Subscription subscription = mModel.fetchOlderTopicComments(topic)
                .subscribe(new Action1<List<TopicComment>>() {
                    @Override
                    public void call(List<TopicComment> topicComments) {
                        Timber.d("comments %s: ", topicComments);
                        mAdapter.setItems(topicComments);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "Failed to load topic comments");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    private void postComment(@NonNull final Topic topic, @NonNull TopicComment comment) {
        final Subscription subscription = mModel.postTopicComment(topic, comment)
                .subscribe(new Action1<TopicComment>() {
                    @Override
                    public void call(TopicComment comment) {
                        Timber.d("Posted comment: %s", comment.getText());
                        fetchNewerCommentsForTopic(topic);
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
