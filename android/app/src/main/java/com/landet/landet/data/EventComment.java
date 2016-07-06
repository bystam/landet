package com.landet.landet.data;

import android.os.Parcel;
import android.os.Parcelable;

public class EventComment extends DataWithId implements Parcelable {
    private String text;

    public EventComment() {}

    public String getText() {
        return text;
    }

    @Override
    public int describeContents() { return 0; }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        super.writeToParcel(dest, flags);
        dest.writeString(this.text);
    }

    protected EventComment(Parcel in) {
        super(in);
        this.text = in.readString();
    }

    public static final Creator<EventComment> CREATOR = new Creator<EventComment>() {
        @Override
        public EventComment createFromParcel(Parcel source) {return new EventComment(source);}

        @Override
        public EventComment[] newArray(int size) {return new EventComment[size];}
    };
}
