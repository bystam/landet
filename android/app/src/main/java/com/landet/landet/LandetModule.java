package com.landet.landet;

import android.content.Context;

import com.landet.landet.api.Backend;
import com.landet.landet.utils.UserManager;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import javax.inject.Singleton;

import dagger.Lazy;
import dagger.Module;
import dagger.Provides;
import okhttp3.Cache;
import okhttp3.Dispatcher;
import okhttp3.OkHttpClient;

@Module
public class LandetModule {

    private static final int CONNECT_TIMEOUT = 60;
    private static final int READ_TIMEOUT = 60;
    private static final int WRITE_TIMEOUT = 60;

    private static final long EIGHT_MB = 1024 * 1024 * 8;
    private Context mApplicationContext;
    private ExecutorService mExecutorService;

    public LandetModule(Context context) {
        this.mApplicationContext = context.getApplicationContext();
        mExecutorService = Executors.newCachedThreadPool();
    }

    @Provides
    @Singleton
    public ExecutorService provideThreadPoolExecutor() {
        return mExecutorService;
    }

    @Provides
    @Singleton
    public Context provideApplicationContext() {
        return mApplicationContext;
    }

    @Provides
    @Singleton
    public UserManager provideUserManager(Context context, Lazy<Backend> backend) {
        return new UserManager(context, backend);
    }

    @Provides
    @Singleton
    public OkHttpClient provideOkHttpClient(Context context, UserManager userManager) {
        return new OkHttpClient.Builder()
                .cache(new Cache(context.getCacheDir(), EIGHT_MB))
                .dispatcher(new Dispatcher(mExecutorService))
                .connectTimeout(CONNECT_TIMEOUT, TimeUnit.SECONDS)
                .readTimeout(READ_TIMEOUT, TimeUnit.SECONDS)
                .writeTimeout(WRITE_TIMEOUT, TimeUnit.SECONDS)
                .addInterceptor(userManager)
                .authenticator(userManager)
                .build();
    }

    @Provides
    @Singleton
    public Backend provideBackend(OkHttpClient okHttpClient) {
        return new Backend(okHttpClient);
    }
}
