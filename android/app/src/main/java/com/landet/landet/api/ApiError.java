package com.landet.landet.api;

public class ApiError extends Exception {
    private String status;
    private String api_code;
    private String message;

    public String getStatus() {
        return status;
    }

    public String getApiCode() {
        return api_code;
    }

    public String getApiMessage() {
        return message;
    }

    @Override
    public String getMessage() {
        return status + ": " + api_code + " " + message;
    }
}
