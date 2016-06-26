package com.landet.landet.data;

import com.google.gson.annotations.SerializedName;

public class Location extends DataWithId {
    @SerializedName("enum_id")
    private String enumId;
    private String name;
    @SerializedName("image_url")
    private String imageUrl;
}
