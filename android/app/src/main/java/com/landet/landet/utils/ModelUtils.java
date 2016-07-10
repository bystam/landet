package com.landet.landet.utils;

import com.landet.landet.api.ApiResponse;

import rx.Observable;
import rx.functions.Func1;

public class ModelUtils {
    public static <T> Func1<ApiResponse<T>, Observable<T>> mapApiResponseToObservable() {
        return new Func1<ApiResponse<T>, Observable<T>>() {
            @Override
            public Observable<T> call(ApiResponse<T> apiResponse) {
                if (apiResponse.isSuccessful()) {
                    return Observable.just(apiResponse.getBody());
                } else {
                    return Observable.error(apiResponse.getError());
                }
            }
        };
    }
}
