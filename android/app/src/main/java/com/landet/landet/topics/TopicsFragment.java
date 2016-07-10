package com.landet.landet.topics;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.landet.landet.BaseFragment;
import com.landet.landet.R;
import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicComment;

import java.util.List;

import rx.Subscription;
import rx.functions.Action1;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;


public class TopicsFragment extends BaseFragment {
    private TopicModel mModel;
    private TopicsAdapter mAdapter;
    private CompositeSubscription mCompositeSubscription;

    public TopicsFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mModel = new TopicModel(mBackend);
        mCompositeSubscription = new CompositeSubscription();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_topics, container, false);
        final RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        mAdapter = new TopicsAdapter(getContext(), new TopicsAdapter.Listener() {
            @Override
            public void onItemClicked(@NonNull Topic item) {
                Toast.makeText(getContext(), item.getTitle(), Toast.LENGTH_SHORT).show();
                fetchOlderCommentsForTopic(item); //TODO Move this to a better place
            }
        });
        recyclerView.setAdapter(mAdapter);
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();

        fetchTopics();
    }

    @Override
    public void onPause() {
        super.onPause();
        mCompositeSubscription.clear();
    }

    private void fetchTopics() {
        final Subscription subscription = mModel.fetchTopics()
                .subscribe(new Action1<List<Topic>>() {
                    @Override
                    public void call(List<Topic> topics) {
                        Timber.d("topics: %s", topics);
                        mAdapter.setItems(topics);
                        if (!topics.isEmpty()) {
                            setActiveTopic(topics.get(0));
                        }
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "failed to fetch topics");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    private void createTopic(@NonNull Topic topic) {
        final Subscription subscription = mModel.createTopic(topic)
                .subscribe(new Action1<Topic>() {
                    @Override
                    public void call(Topic topic) {
                        fetchTopics();
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to create topic");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    //Call this when swiping to a new topic. Will load comments for that topic.
    private void setActiveTopic(Topic topic) {
        final Subscription subscription = mModel.initialLoad(topic)
                .subscribe(new Action1<List<TopicComment>>() {
                    @Override
                    public void call(List<TopicComment> topicComments) {
                        Timber.d("Comments %s", topicComments);
                        //TODO Set the comments in the adapter
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to fetch comments");
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
                        //TODO Set the comments in the adapter
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "Failed to load topic comments");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    // Call when posting a message or when you want the latest comments for some other reason
    private void fetchNewerCommentsForTopic(@NonNull Topic topic) {
        final Subscription subscription = mModel.fetchNewerTopicComments(topic)
                .subscribe(new Action1<List<TopicComment>>() {
                    @Override
                    public void call(List<TopicComment> topicComments) {
                        Timber.d("comments %s: ", topicComments);
                        //TODO Set the comments in the adapter
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
        final Subscription subscription = mModel.postComment(topic, comment)
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