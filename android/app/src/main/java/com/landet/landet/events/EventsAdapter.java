package com.landet.landet.events;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.landet.landet.R;
import com.landet.landet.data.Event;

import java.util.ArrayList;
import java.util.List;

public class EventsAdapter extends RecyclerView.Adapter<EventsAdapter.EventViewHolder> {
    private List<Event> mEvents;
    private Context mContext;

    public EventsAdapter(@NonNull Context context) {
        mEvents = new ArrayList<>();
        mContext = context;
    }

    public void setItems(List<Event> events) {
        mEvents.clear();
        mEvents.addAll(events);
        notifyDataSetChanged();
    }

    private Event getItem(int position) {
        return mEvents.get(position);
    }

    @Override
    public int getItemCount() {
        return mEvents.size();
    }

    @Override
    public EventViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        final View view = LayoutInflater.from(mContext).inflate(R.layout.list_item_event, parent, false);
        return new EventViewHolder(view);
    }

    @Override
    public void onBindViewHolder(EventViewHolder holder, int position) {
        Event event = getItem(position);
        holder.title.setText(event.getTitle());
    }

    public class EventViewHolder extends RecyclerView.ViewHolder {
        private TextView title;

        public EventViewHolder(View itemView) {
            super(itemView);
            title = (TextView) itemView.findViewById(R.id.title);
        }
    }
}
