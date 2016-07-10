package com.landet.landet.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

import org.joda.time.DateTime;

public class TopicComment extends DataWithId implements Parcelable {
    private String text;
    @SerializedName("comment_time")
    private DateTime dateTime;
    private User author;

    public TopicComment() {}

    public TopicComment(String text) {
        this.text = text;
    }

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

    protected TopicComment(Parcel in) {
        super(in);
        this.text = in.readString();
        this.dateTime = (DateTime) in.readSerializable();
        this.author = in.readParcelable(User.class.getClassLoader());
    }

    public static final Creator<TopicComment> CREATOR = new Creator<TopicComment>() {
        @Override
        public TopicComment createFromParcel(Parcel source) {return new TopicComment(source);}

        @Override
        public TopicComment[] newArray(int size) {return new TopicComment[size];}
    };
}
