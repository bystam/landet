package com.landet.landet.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

public abstract class DataWithId implements Parcelable {
    @SerializedName("id")
    protected Long _id;

    public Long getId() {
        return _id;
    }

    public DataWithId() {}

    public DataWithId(Parcel in) {
        _id = in.readLong();
    }

    public void setId(Long id) {
        this._id = id;
    }

    public void writeToParcel(Parcel out, int flags) {
        out.writeLong(_id);
    }
}
