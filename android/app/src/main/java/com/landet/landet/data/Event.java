package com.landet.landet.data;

import com.google.gson.annotations.SerializedName;

import org.joda.time.DateTime;

public class Event extends DataWithId {
    private String title;
    private String body;
    @SerializedName("event_time")
    private DateTime eventTime;
    private User creator;
    private Location location;
}
