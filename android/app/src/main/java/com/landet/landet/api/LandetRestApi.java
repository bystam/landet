package com.landet.landet.api;

import com.landet.landet.data.Event;
import com.landet.landet.data.EventComment;
import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicCommentListWrapper;
import com.landet.landet.data.User;

import java.util.List;

import retrofit2.adapter.rxjava.Result;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Path;
import rx.Observable;

public interface LandetRestApi {
    String URL = "http://landet.herokuapp.com";

    @POST("users/login")
    Observable<Result<AuthenticationResult>> login(@Body AuthenticationParameters authenticationParameters);

    @POST("users/create")
    Observable<Result<User>> register(@Body User user);

    @POST("sessions/refresh")
    Observable<Result<AuthenticationResult>> refreshAuthToken(@Body AuthenticationParameters authenticationParameters);

    @GET("events")
    Observable<Result<List<Event>>> events();

    @GET("events/{eventId}/comments")
    Observable<Result<List<EventComment>>> eventComments(@Path("eventId") Long eventId);

    @GET("topics")
    Observable<Result<List<Topic>>> topics();

    @GET("topics/{topicId}/comments")
    Observable<Result<TopicCommentListWrapper>> topicComments(@Path("topicId") Long topicId);
}
