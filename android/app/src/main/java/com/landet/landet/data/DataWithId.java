package com.landet.landet.data;

import com.google.gson.annotations.SerializedName;

public class DataWithId {
    @SerializedName("id")
    protected Long _id;

    public Long getId() {
        return _id;
    }

    public void setId(Long id) {
        this._id = id;
    }
}
