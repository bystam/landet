package com.landet.landet.topics;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.ActionBar;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.landet.landet.BaseActivity;
import com.landet.landet.R;
import com.landet.landet.data.Topic;

import rx.Subscription;
import rx.functions.Action1;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;

/**
 * Created by shayan on 11/07/16.
 */
public class CreateTopicActivity extends BaseActivity {

    private TopicModel mModel;
    private CompositeSubscription mCompositeSubscription;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_create_topic);

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }

        mModel = new TopicModel(mBackend);
        mCompositeSubscription = new CompositeSubscription();

        final EditText title = (EditText) findViewById(R.id.title);
        Button button = (Button) findViewById(R.id.button);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String s = title.getText().toString();
                if (s.equals("")) {
                    Toast.makeText(CreateTopicActivity.this, "Error: Empty title", Toast.LENGTH_SHORT).show();
                } else {
                    createTopic(new Topic(s));
                }
            }
        });
    }

    private void createTopic(@NonNull Topic topic) {
        final Subscription subscription = mModel.createTopic(topic)
                .subscribe(new Action1<Topic>() {
                    @Override
                    public void call(Topic topic) {
                        Intent intent = getIntent();
                        setResult(RESULT_OK, intent);
                        finish();
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to create topic");
                    }
                });
        mCompositeSubscription.add(subscription);
    }
}
