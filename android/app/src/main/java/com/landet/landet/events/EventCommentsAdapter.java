package com.landet.landet.events;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.landet.landet.R;
import com.landet.landet.data.EventComment;

import org.joda.time.format.DateTimeFormat;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by shayan on 08/07/16.
 */
public class EventCommentsAdapter extends RecyclerView.Adapter<EventCommentsAdapter.EventCommentsViewHolder> {
    private Context mContext;
    private List<EventComment> mComments = new ArrayList<>();

    public EventCommentsAdapter(@NonNull Context context) {
        mContext = context;
    }

    @Override
    public EventCommentsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.list_item_comment, parent, false);
        return new EventCommentsViewHolder(view);
    }

    @Override
    public void onBindViewHolder(EventCommentsViewHolder holder, int position) {
        EventComment comment = getItem(position);
        holder.author.setText(comment.getAuthor().getName());
        String day = comment.getDateTime().dayOfWeek().getAsText();
        String time = DateTimeFormat.forPattern("HH:mm").print(comment.getDateTime());
        holder.dateTime.setText(mContext.getString(R.string.day_time, day, time));
        holder.body.setText(comment.getText());
    }

    public EventComment getItem(int position) {
        return mComments.get(position);
    }

    public void setItems(List<EventComment> comments) {
        mComments.clear();
        mComments.addAll(comments);
        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        return mComments.size();
    }

    public class EventCommentsViewHolder extends RecyclerView.ViewHolder {
        public final TextView author;
        public final TextView dateTime;
        public final TextView body;

        public EventCommentsViewHolder(View view) {
            super(view);
            author = (TextView) view.findViewById(R.id.author);
            dateTime = (TextView) view.findViewById(R.id.date_time);
            body = (TextView) view.findViewById(R.id.body);
        }
    }
}
