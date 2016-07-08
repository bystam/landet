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

import rx.functions.Action1;
import timber.log.Timber;


public class TopicsFragment extends BaseFragment {
    private TopicModel mModel;
    private TopicsAdapter mAdapter;

    public TopicsFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mModel = new TopicModel(mBackend);
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

        mModel.fetchTopics()
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
    }

    private void setActiveTopic(Topic topic) {
        //TODO what does this even mean?
        mModel.initialLoad(topic)
                .subscribe(new Action1<List<TopicComment>>() {
                    @Override
                    public void call(List<TopicComment> topicComments) {
                        Timber.d("Comments %s", topicComments);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to fetch comments");
                    }
                });
    }

    private void fetchOlderCommentsForTopic(@NonNull Topic topic) {
        mModel.fetchOlderTopicComments(topic)
                .subscribe(new Action1<List<TopicComment>>() {
                    @Override
                    public void call(List<TopicComment> topicComments) {
                        Timber.d("comments %s: ", topicComments);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "Failed to load topic comments");
                    }
                });
    }

    private void fetchNewerCommentsForTopic(@NonNull Topic topic) {
        mModel.fetchNewerTopicComments(topic)
                .subscribe(new Action1<List<TopicComment>>() {
                    @Override
                    public void call(List<TopicComment> topicComments) {
                        Timber.d("comments %s: ", topicComments);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "Failed to load topic comments");
                    }
                });
    }
}