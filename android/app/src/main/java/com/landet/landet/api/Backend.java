package com.landet.landet.api;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.landet.landet.data.Event;
import com.landet.landet.data.EventComment;
import com.landet.landet.data.Location;
import com.landet.landet.data.MapContent;
import com.landet.landet.data.Topic;
import com.landet.landet.data.TopicComment;
import com.landet.landet.data.TopicCommentListWrapper;
import com.landet.landet.data.User;

import org.joda.time.DateTime;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.List;

import okhttp3.OkHttpClient;
import okhttp3.ResponseBody;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava.Result;
import retrofit2.adapter.rxjava.RxJavaCallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;
import rx.Observable;
import rx.functions.Func1;
import timber.log.Timber;

public class Backend {
    private final Gson mGson;

    private LandetRestApi mApi;

    public Backend(@NonNull OkHttpClient okHttpClient) {
        mGson = new GsonBuilder()
                .registerTypeAdapter(DateTime.class, new DateTimeTypeConverter())
                .create();
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(LandetRestApi.URL)
                .addConverterFactory(GsonConverterFactory.create(mGson))
                .addCallAdapterFactory(RxJavaCallAdapterFactory.create())
                .client(okHttpClient)
                .build();

        mApi = retrofit.create(LandetRestApi.class);
    }

    public Observable<ApiResponse<AuthenticationResult>> login(@NonNull String username, @NonNull String password) {
        return mApi.login(new AuthenticationParameters(username, password))
                .map(this.<AuthenticationResult>resultToApiResponse());
    }

    public Observable<ApiResponse<User>> register(@NonNull String username, @NonNull String password, @NonNull String name) {
        return mApi.register(new User(username, password, name))
                .map(this.<User>resultToApiResponse());
    }

    public Observable<ApiResponse<AuthenticationResult>> refreshAuthToken(@Nullable String refreshToken) {
        return mApi.refreshAuthToken(new AuthenticationParameters(refreshToken))
                .map(this.<AuthenticationResult>resultToApiResponse());
    }

    public Observable<ApiResponse<List<Event>>> fetchEvents() {
        return mApi.events()
                .map(this.<List<Event>>resultToApiResponse());
    }

    public Observable<ApiResponse<Event>> createEvent(@NonNull Event event) {
        return mApi.createEvent(event)
                .map(this.<Event>resultToApiResponse());
    }

    public Observable<ApiResponse<List<EventComment>>> fetchEventComments(@NonNull Event event) {
        return mApi.eventComments(event.getId())
                .map(this.<List<EventComment>>resultToApiResponse());
    }

    public Observable<ApiResponse<EventComment>> postEventComment(@NonNull Event event, @NonNull EventComment comment) {
        return mApi.postEventComment(event.getId(), comment)
                .map(this.<EventComment>resultToApiResponse());
    }

    public Observable<ApiResponse<List<Topic>>> fetchTopics() {
        return mApi.topics()
                .map(this.<List<Topic>>resultToApiResponse());
    }

    public Observable<ApiResponse<Topic>> createTopic(@NonNull Topic topic) {
        return mApi.createTopic(topic)
                .map(this.<Topic>resultToApiResponse());
    }

    public Observable<ApiResponse<TopicCommentListWrapper>> fetchTopicComments(@NonNull Topic topic,
                                                                               @Nullable DateTime before,
                                                                               @Nullable DateTime after) {
        return mApi.topicComments(topic.getId(),
                                  DateTimeTypeConverter.toString(before),
                                  DateTimeTypeConverter.toString(after))
                .map(this.<TopicCommentListWrapper>resultToApiResponse());
    }

    public Observable<ApiResponse<TopicComment>> postTopicComment(@NonNull Topic topic, @NonNull TopicComment comment) {
        return mApi.postTopicComment(topic.getId(), comment)
                .map(this.<TopicComment>resultToApiResponse());
    }

    public Observable<ApiResponse<List<Location>>> fetchLocations() {
        return mApi.locations()
                .map(this.<List<Location>>resultToApiResponse());
    }

    public Observable<ApiResponse<MapContent>> fetchMapContent() {
        return mApi.mapContent()
                .map(this.<MapContent>resultToApiResponse());
    }

    @NonNull
    private <T> ApiResponse<T> getApiResponseForResult(@NonNull Result<T> result) {
        if (result.isError()) {
            return getResponseForError(result.error());
        } else if (result.response().isSuccessful()) {
            return getResponseForSuccess(result.response());
        } else {
            return getResponseForHttpError(result.response());
        }
    }

    @NonNull
    private static <T> ApiResponse<T> getResponseForSuccess(@NonNull Response<T> response) {
        return ApiResponse.<T>newBuilder()
                .code(response.code())
                .message(response.message())
                .body(response.body())
                .build();
    }

    private <T> ApiResponse<T> getResponseForHttpError(@NonNull Response<T> response) {
        if (response.code() >= 400 && response.code() < 500) { // Request was processed correctly but the api returned an error, build error object from response body
            final ResponseBody responseBody = response.errorBody();
            WrappedApiError wrappedApiError = mGson.fromJson(new InputStreamReader(responseBody.byteStream()), WrappedApiError.class);
            ApiError error = wrappedApiError != null ? wrappedApiError.landet_error : null;
            return ApiResponse.<T>newBuilder()
                    .code(response.code())
                    .message(response.message())
                    .error(error)
                    .build();
        } else { // Some other http code than 2xx or 4xx, probably a server error (5xx)
            return ApiResponse.<T>newBuilder()
                    .code(response.code())
                    .message(response.message())
                    .error(new IOException())
                    .build();
        }
    }

    @NonNull
    private static <T> ApiResponse<T> getResponseForError(@NonNull Throwable e) {
        Timber.e(e, e.getMessage());
        if (e instanceof IOException) { // Could not contact server, probably a network problem
            return ApiResponse.<T>newBuilder()
                    .code(ApiResponse.STATUS_REQUEST_FAILED)
                    .message("No response from server")
                    .error(e)
                    .build();
        } else if (e instanceof RuntimeException) { // Catches response format errors that gson fails to parse
            return ApiResponse.<T>newBuilder()
                    .code(ApiResponse.STATUS_REQUEST_FAILED)
                    .message("Unknown response format from server")
                    .error(e)
                    .build();
        } else {
            return ApiResponse.<T>newBuilder()
                    .code(ApiResponse.STATUS_REQUEST_FAILED)
                    .message("Unknown error")
                    .error(e)
                    .build();
        }
    }

    @NonNull
    private <T> Func1<Result<T>, ApiResponse<T>> resultToApiResponse() {
        return new Func1<Result<T>, ApiResponse<T>>() {
            @Override
            public ApiResponse<T> call(Result<T> result) {
                return getApiResponseForResult(result);
            }
        };
    }
}
