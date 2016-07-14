package com.landet.landet.topics;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityOptionsCompat;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.landet.landet.BaseFragment;
import com.landet.landet.FabFragment;
import com.landet.landet.R;
import com.landet.landet.data.Topic;

import java.util.List;

import rx.Subscription;
import rx.functions.Action1;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;


public class TopicsFragment extends BaseFragment implements FabFragment {
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
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), 2));
        mAdapter = new TopicsAdapter(getContext(), new TopicsAdapter.Listener() {
            @Override
            public void onItemClicked(@NonNull Topic topic, View view) {
                final Intent intent = new Intent(getContext(), TopicDetailsActivity.class);
                intent.putExtra("topic", topic);
                ActivityOptionsCompat options = ActivityOptionsCompat.
                        makeSceneTransitionAnimation(getActivity(), view, "topic_circle");
                startActivity(intent, options.toBundle());
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

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && resultCode == Activity.RESULT_OK) {
            fetchTopics();
        }
    }

    private void fetchTopics() {
        final Subscription subscription = mModel.fetchTopics()
                .subscribe(new Action1<List<Topic>>() {
                    @Override
                    public void call(List<Topic> topics) {
                        Timber.d("topics: %s", topics);
                        mAdapter.setItems(topics);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "failed to fetch topics");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    @Override
    public void onFabClicked() {
        Intent intent = new Intent(getActivity(), CreateTopicActivity.class);
        startActivityForResult(intent, 1);
    }
}