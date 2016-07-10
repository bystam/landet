package com.landet.landet.topics;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.landet.landet.R;
import com.landet.landet.data.TopicComment;

import org.joda.time.format.DateTimeFormat;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by shayan on 10/07/16.
 */
public class TopicCommentAdapter extends RecyclerView.Adapter<TopicCommentAdapter.CommentViewHolder> {
    private List<TopicComment> mComments = new ArrayList<>();
    private Context mContext;

    public TopicCommentAdapter(Context context) {
        mContext = context;
    }

    @Override
    public TopicCommentAdapter.CommentViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.list_item_comment, parent, false);
        return new CommentViewHolder(view);
    }

    @Override
    public void onBindViewHolder(TopicCommentAdapter.CommentViewHolder holder, int position) {
        TopicComment comment = getItem(position);
        holder.author.setText(comment.getAuthor().getName());
        String day = comment.getDateTime().dayOfWeek().getAsText();
        String time = DateTimeFormat.forPattern("HH:mm").print(comment.getDateTime());
        holder.dateTime.setText(mContext.getString(R.string.day_time, day, time));
        holder.body.setText(comment.getText());
    }

    public TopicComment getItem(int position) {
        return mComments.get(position);
    }

    public void setItems(List<TopicComment> comments) {
        mComments.clear();
        mComments.addAll(comments);
        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        return mComments.size();
    }

    public class CommentViewHolder extends RecyclerView.ViewHolder {
        private final TextView author;
        public final TextView dateTime;
        public final TextView body;

        public CommentViewHolder(View view) {
            super(view);
            author = (TextView) view.findViewById(R.id.author);
            dateTime = (TextView) view.findViewById(R.id.date_time);
            body = (TextView) view.findViewById(R.id.body);
        }
    }
}
