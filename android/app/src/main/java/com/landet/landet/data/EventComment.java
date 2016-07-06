package com.landet.landet.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

import org.joda.time.DateTime;

public class EventComment extends DataWithId implements Parcelable {
    private String text;
    @SerializedName("comment_time")
    private DateTime dateTime;
    private User author;

    public EventComment() {}

    public String getText() {
        return text;
    }

    public DateTime getDateTime() {
        return dateTime;
    }

    public User getAuthor() {
        return author;
    }


    @Override
    public int describeContents() { return 0; }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        super.writeToParcel(dest, flags);
        dest.writeString(this.text);
        dest.writeSerializable(this.dateTime);
        dest.writeParcelable(this.author, flags);
    }

    protected EventComment(Parcel in) {
        super(in);
        this.text = in.readString();
        this.dateTime = (DateTime) in.readSerializable();
        this.author = in.readParcelable(User.class.getClassLoader());
    }

    public static final Creator<EventComment> CREATOR = new Creator<EventComment>() {
        @Override
        public EventComment createFromParcel(Parcel source) {return new EventComment(source);}

        @Override
        public EventComment[] newArray(int size) {return new EventComment[size];}
    };
}
