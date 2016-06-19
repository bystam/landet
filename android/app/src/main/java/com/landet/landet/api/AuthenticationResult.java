package com.landet.landet.api;

import com.google.gson.annotations.SerializedName;

public class AuthenticationResult {
    @SerializedName("token")
    public String authToken;
    @SerializedName("refresh_token")
    public String refreshToken;
}
