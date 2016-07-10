package com.landet.landet.topics;

import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.MenuItem;
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

        TextView title = (TextView) findViewById(R.id.title);
        title.setText(mTopic.getTitle());

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
            private int visibleThreshold = 10;
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
                            <= (firstVisibleItem + visibleThreshold)) {
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
}
