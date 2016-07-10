package com.landet.landet.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

import org.joda.time.DateTime;

public class Event extends DataWithId implements Parcelable {
    private String title;
    private String body;
    @SerializedName("event_time")
    private DateTime eventTime;
    private User creator;
    private Location location;
    @SerializedName("location_id")
    private Long locationId;

    public Event() {}

    public Event(String title, String body, DateTime eventTime, Location location) {
        this.title = title;
        this.body = body;
        this.eventTime = eventTime;
        this.location = location;
        locationId = location.getId();
    }

    public String getTitle() {
        return title;
    }

    public String getBody() {
        return body;
    }

    public DateTime getEventTime() {
        return eventTime;
    }

    public User getCreator() {
        return creator;
    }

    public Location getLocation() {
        return location;
    }

    @Override
    public int describeContents() { return 0; }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        super.writeToParcel(dest, flags);
        dest.writeString(this.title);
        dest.writeString(this.body);
        dest.writeSerializable(this.eventTime);
        dest.writeParcelable(this.creator, flags);
        dest.writeParcelable(this.location, flags);
    }

    protected Event(Parcel in) {
        super(in);
        this.title = in.readString();
        this.body = in.readString();
        this.eventTime = (DateTime) in.readSerializable();
        this.creator = in.readParcelable(User.class.getClassLoader());
        this.location = in.readParcelable(Location.class.getClassLoader());
    }

    public static final Creator<Event> CREATOR = new Creator<Event>() {
        @Override
        public Event createFromParcel(Parcel source) {return new Event(source);}

        @Override
        public Event[] newArray(int size) {return new Event[size];}
    };
}
