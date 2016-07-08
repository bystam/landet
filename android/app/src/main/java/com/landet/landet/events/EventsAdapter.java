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

import org.joda.time.format.DateTimeFormat;

import java.util.ArrayList;
import java.util.List;

public class EventsAdapter extends RecyclerView.Adapter<EventsAdapter.EventViewHolder> {
    private EventsListener mListener;
    private List<Event> mEvents;
    private Context mContext;

    public EventsAdapter(@NonNull Context context, EventsListener listener) {
        mEvents = new ArrayList<>();
        mListener = listener;
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
        String day = event.getEventTime().dayOfWeek().getAsText();
        String time = DateTimeFormat.forPattern("HH:mm").print(event.getEventTime());
        String place = event.getLocation().getName();
        holder.timePlace.setText(mContext.getString(R.string.day_time_at_place, day, time, place));
        holder.author.setText(mContext.getString(R.string.by_author, event.getCreator().getName()));
        holder.body.setText(event.getBody());
    }

    public class EventViewHolder extends RecyclerView.ViewHolder {
        private TextView title;
        private TextView timePlace;
        private TextView author;
        private TextView body;

        public EventViewHolder(View itemView) {
            super(itemView);
            title = (TextView) itemView.findViewById(R.id.title);
            timePlace = (TextView) itemView.findViewById(R.id.time_place);
            author = (TextView) itemView.findViewById(R.id.author);
            body = (TextView) itemView.findViewById(R.id.body);
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Event event = getItem(getAdapterPosition());
                    if (event != null && mListener != null) {
                        mListener.onEventClicked(event);
                    }
                }
            });
        }
    }

    public interface EventsListener {
        void onEventClicked(@NonNull Event event);
    }
}
