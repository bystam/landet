package com.landet.landet.api;

import com.landet.landet.data.Event;

import java.util.List;

import retrofit2.adapter.rxjava.Result;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import rx.Observable;

public interface LandetRestApi {
    String URL = "http://landet.herokuapp.com";

    @POST("users/login")
    Observable<Result<AuthenticationResult>> login(@Body AuthenticationParameters authenticationParameters);

    @POST("sessions/refresh")
    Observable<Result<AuthenticationResult>> refreshAuthToken(@Body AuthenticationParameters authenticationParameters);

    @GET("events")
    Observable<Result<List<Event>>> events();
}
