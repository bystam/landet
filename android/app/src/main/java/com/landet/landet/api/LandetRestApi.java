package com.landet.landet.api;

import com.landet.landet.data.Event;
import com.landet.landet.data.EventComment;
import com.landet.landet.data.Location;
import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicComment;
import com.landet.landet.data.TopicCommentListWrapper;
import com.landet.landet.data.User;

import java.util.List;

import retrofit2.adapter.rxjava.Result;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.POST;
import retrofit2.http.Path;
import retrofit2.http.Query;
import rx.Observable;

public interface LandetRestApi {
    String URL = "http://landet.herokuapp.com";

    @POST("users/login")
    Observable<Result<AuthenticationResult>> login(@Body AuthenticationParameters authenticationParameters);

    @POST("users")
    Observable<Result<User>> register(@Body User user);

    @POST("sessions/refresh")
    Observable<Result<AuthenticationResult>> refreshAuthToken(@Body AuthenticationParameters authenticationParameters);

    @GET("events")
    Observable<Result<List<Event>>> events();

    @POST("events")
    Observable<Result<Event>> createEvent(@Body Event event);

    @GET("events/{eventId}/comments")
    Observable<Result<List<EventComment>>> eventComments(@Path("eventId") Long eventId);

    @POST("events/{eventId}/comments")
    Observable<Result<EventComment>> postEventComment(@Path("eventId") Long eventId, @Body EventComment comment);

    @GET("topics")
    Observable<Result<List<Topic>>> topics();

    @POST("topics")
    Observable<Result<Topic>> createTopic(@Body Topic topic);

    @Headers("Cache-Control: no-cache")
    @GET("topics/{topicId}/comments")
    Observable<Result<TopicCommentListWrapper>> topicComments(
            @Path("topicId") Long topicId,
            @Query("pageBefore") String before,
            @Query("after") String after);

    @POST("topics/{topicId}/comments")
    Observable<Result<TopicComment>> postTopicComment(@Path("topicId") Long topicId, @Body TopicComment comment);

    @GET("locations")
    Observable<Result<List<Location>>> locations();
}
