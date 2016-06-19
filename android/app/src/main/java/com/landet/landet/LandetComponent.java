package com.landet.landet;

import android.content.Context;

import com.landet.landet.api.Backend;
import com.landet.landet.utils.UserManager;

import javax.inject.Singleton;

import dagger.Component;
import okhttp3.OkHttpClient;

@Component(modules = LandetModule.class)
@Singleton
public interface LandetComponent {
    void inject(BaseFragment baseFragment);

    OkHttpClient okHttpClient();

    Context applicationContext();

    Backend backend();

    UserManager userManager();
}
