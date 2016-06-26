package com.landet.landet.utils;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.WorkerThread;
import android.support.v4.content.LocalBroadcastManager;

import com.landet.landet.LandetApplication;
import com.landet.landet.api.ApiResponse;
import com.landet.landet.api.AuthenticationResult;
import com.landet.landet.api.Backend;

import java.io.IOException;

import dagger.Lazy;
import okhttp3.Authenticator;
import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.Route;
import rx.Observable;
import rx.functions.Func1;
import timber.log.Timber;

public class UserManager implements Authenticator, Interceptor {
    public static final String AUTH_TOKEN = "authToken";
    public static final String REFRESH_TOKEN = "refreshToken";
    public static final String AUTHORIZATION = "Authorization";
    public static final String EVENT_USER_WAS_LOGGED_OUT = "userWasLoggedOut";

    @NonNull
    private final LandetApplication mApplication;
    @NonNull
    private final Lazy<Backend> mBackend;
    @NonNull
    private final SharedPreferences mPreferences;

    public UserManager(@NonNull Context context, @NonNull Lazy<Backend> backend) {
        mApplication = (LandetApplication) context.getApplicationContext();
        mBackend = backend;
        mPreferences = mApplication.getSharedPreferences(Constants.LANDET_PREFERENCES, Context.MODE_PRIVATE);
    }

    public Observable<Void> login(@NonNull String username, @NonNull String password) {
        return mBackend.get().login(username, password)
                .flatMap(new Func1<ApiResponse<AuthenticationResult>, Observable<Void>>() {
                    @Override
                    public Observable<Void> call(ApiResponse<AuthenticationResult> apiResponse) {
                        if (apiResponse.isSuccessful()) {
                            storeAuthToken(apiResponse.getBody().authToken, apiResponse.getBody().refreshToken);
                            return Observable.empty();
                        } else {
                            return Observable.error(apiResponse.getError());
                        }
                    }
                });
    }

    public Observable<Void> register(@NonNull String username, @NonNull String password, @NonNull String name) {
        return Observable.empty();
    }

    public void logout() {
        storeAuthToken(null, null);
    }

    public boolean isLoggedIn() {
        return getAuthToken() != null;
    }

    @Override
    public Response intercept(final Interceptor.Chain chain) throws IOException {
        final String authToken = getAuthToken();
        Request request = chain.request();
        if (authToken != null && requestNeedsAuthToken(request)) {
            request = requestWithHeader(request, AUTHORIZATION, basic(authToken));
        }
        return chain.proceed(request);
    }

    @Override
    public Request authenticate(final Route route, final Response response) throws IOException {
        if (response.request().url().pathSegments().contains("login") || response.request().url().pathSegments().contains("sessions")) {
            return null; //Failed to get authentication token, so don't try to reauthenticate
        }
        final Response priorResponse = response.priorResponse();
        if (priorResponse != null) {
            // If we have already tried to refresh the token and it still fails, stop trying
            return null;
        }
        final String authToken = refreshAuthToken(getRefreshToken());
        if (authToken == null) {
            return null;
        }
        return requestWithHeader(response.request(), AUTHORIZATION, basic(authToken));
    }

    @WorkerThread
    @Nullable
    private String refreshAuthToken(@Nullable final String refreshToken) {
        try {
            return mBackend.get().refreshAuthToken(refreshToken)
                    .map(new Func1<ApiResponse<AuthenticationResult>, String>() {
                        @Override
                        public String call(ApiResponse<AuthenticationResult> apiResponse) {
                            if (apiResponse.isSuccessful() && apiResponse.getBody() != null) {
                                AuthenticationResult auth = apiResponse.getBody();
                                storeAuthToken(auth.authToken, refreshToken);
                                Timber.d("Successfully extended login session");
                                return auth.authToken;
                            } else if (apiResponse.getCode() >= 400 && apiResponse.getCode() < 500) {
                                //Server rejected refresh attempt - end current session since we are not able to continue using it
                                logout();
                                LocalBroadcastManager.getInstance(mApplication).sendBroadcast(new Intent(EVENT_USER_WAS_LOGGED_OUT));
                            }
                            return null;
                        }
                    })
                    .toBlocking()
                    .first();
        } catch (Exception e) {
            Timber.e(e, "Unable to refresh bearer token");
            return null;
        }
    }

    @Nullable
    private String getAuthToken() {
        return mPreferences.getString(AUTH_TOKEN, null);
    }

    @Nullable
    private String getRefreshToken() {
        return mPreferences.getString(REFRESH_TOKEN, null);
    }

    private void storeAuthToken(@Nullable String authToken, @Nullable String refreshToken) {
        mPreferences.edit()
                .putString(AUTH_TOKEN, authToken)
                .putString(REFRESH_TOKEN, refreshToken)
                .apply();
    }

    private boolean requestNeedsAuthToken(@NonNull Request request) {
        if (request.url().pathSegments().contains("events")) {
            return true;
        }
        return false;
    }

    private String basic(@NonNull String token) {
        return "Basic " + token;
    }

    @NonNull
    private Request requestWithHeader(@NonNull Request request, @NonNull String header, @NonNull String value) {
        return request.newBuilder()
                .header(header, value)
                .build();
    }
}
