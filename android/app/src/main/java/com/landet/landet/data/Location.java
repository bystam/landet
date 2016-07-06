package com.landet.landet.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

public class Location extends DataWithId implements Parcelable {
    @SerializedName("enum_id")
    private String enumId;
    private String name;
    @SerializedName("image_url")
    private String imageUrl;

    public Location() {}

    @Override
    public int describeContents() { return 0; }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        super.writeToParcel(dest, flags);
        dest.writeString(this.enumId);
        dest.writeString(this.name);
        dest.writeString(this.imageUrl);
    }

    protected Location(Parcel in) {
        super(in);
        this.enumId = in.readString();
        this.name = in.readString();
        this.imageUrl = in.readString();
    }

    public static final Creator<Location> CREATOR = new Creator<Location>() {
        @Override
        public Location createFromParcel(Parcel source) {return new Location(source);}

        @Override
        public Location[] newArray(int size) {return new Location[size];}
    };
}
