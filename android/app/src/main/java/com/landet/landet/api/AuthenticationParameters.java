package com.landet.landet.api;

import com.google.gson.annotations.SerializedName;

public class AuthenticationParameters {
    private String username;
    private String password;
    @SerializedName("refresh_token")
    private String refreshToken;

    public AuthenticationParameters(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public AuthenticationParameters(String refreshToken) {
        this.refreshToken = refreshToken;
    }
}
