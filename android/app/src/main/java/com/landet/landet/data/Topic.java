package com.landet.landet.data;

import android.os.Parcel;
import android.os.Parcelable;

public class Topic extends DataWithId implements Parcelable {
    private String title;
    private User author;

    public Topic() {}

    public String getTitle() {
        return title;
    }

    public User getAuthor() {
        return author;
    }

    @Override
    public int describeContents() { return 0; }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        super.writeToParcel(dest, flags);
        dest.writeString(this.title);
        dest.writeParcelable(this.author, flags);
    }

    protected Topic(Parcel in) {
        super(in);
        this.title = in.readString();
        this.author = in.readParcelable(User.class.getClassLoader());
    }

    public static final Creator<Topic> CREATOR = new Creator<Topic>() {
        @Override
        public Topic createFromParcel(Parcel source) {return new Topic(source);}

        @Override
        public Topic[] newArray(int size) {return new Topic[size];}
    };
}
