package com.landet.landet.api;

import com.landet.landet.data.Event;

import java.util.List;

import retrofit2.adapter.rxjava.Result;
import retrofit2.http.GET;
import rx.Observable;

public interface LandetRestApi {
    String URL = "http://landet.herokuapp.com";

    @GET("events")
    Observable<Result<List<Event>>> events();
}
