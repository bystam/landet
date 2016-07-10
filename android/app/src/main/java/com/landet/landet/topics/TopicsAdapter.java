package com.landet.landet.topics;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.landet.landet.R;
import com.landet.landet.data.Topic;

import java.util.ArrayList;
import java.util.List;

public class TopicsAdapter extends RecyclerView.Adapter<TopicsAdapter.ViewHolder> {
    private Listener mListener;
    private List<Topic> mItems;
    private Context mContext;

    public TopicsAdapter(@NonNull Context context, Listener listener) {
        mItems = new ArrayList<>();
        mListener = listener;
        mContext = context;
    }

    public void setItems(List<Topic> items) {
        mItems.clear();
        mItems.addAll(items);
        notifyDataSetChanged();
    }

    private Topic getItem(int position) {
        return mItems.get(position);
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        final View view = LayoutInflater.from(mContext).inflate(R.layout.list_item_topic, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        Topic item = getItem(position);
        holder.title.setText(item.getTitle());
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        private TextView title;

        public ViewHolder(final View itemView) {
            super(itemView);
            title = (TextView) itemView.findViewById(R.id.title);
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int position = getAdapterPosition();
                    if (position >= 0) {
                        Topic item = getItem(position);
                        if (item != null && mListener != null) {
                            mListener.onItemClicked(item, itemView);
                        }
                    }
                }
            });
        }
    }

    public interface Listener {
        void onItemClicked(@NonNull Topic item, View view);
    }
}
