package com.landet.landet.api;

public class ApiResponse<T> {
    public static final int STATUS_REQUEST_FAILED = -1;

    private int code;
    private String message;
    private T body;
    private Throwable error;

    public ApiResponse(int code, String message, T body, Throwable error) {
        this.code = code;
        this.message = message;
        this.body = body;
        this.error = error;
    }

    public static <C> Builder<C> newBuilder() {
        return new Builder<>();
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public T getBody() {
        return body;
    }

    public Throwable getError() {
        return error;
    }

    public boolean isSuccessful() {
        return code >= 200 && code < 300;
    }

    public static class Builder<T> {
        private int mCode;
        private String mMessage;
        private T mBody;
        private Throwable mError;

        public Builder<T> code(int code) {
            mCode = code;
            return this;
        }

        public Builder<T> message(String message) {
            mMessage = message;
            return this;
        }

        public Builder<T> body(T body) {
            mBody = body;
            return this;
        }

        public Builder<T> error(Throwable error) {
            mError = error;
            return this;
        }

        public ApiResponse<T> build() {
            return new ApiResponse<>(mCode, mMessage, mBody, mError);
        }
    }
}
