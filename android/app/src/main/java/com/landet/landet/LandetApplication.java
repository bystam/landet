package com.landet.landet;

import android.app.Application;

import timber.log.Timber;

public class LandetApplication extends Application {
    private LandetComponent mLandetComponent;

    @Override
    public void onCreate() {
        super.onCreate();
        LandetModule landetModule = new LandetModule(this);
        mLandetComponent = DaggerLandetComponent.builder()
                .landetModule(landetModule)
                .build();

        Timber.plant(BuildConfig.DEBUG ? new Timber.DebugTree() : new ReleaseTree());
    }

    public LandetComponent getLandetComponent() {
        return mLandetComponent;
    }

    private class ReleaseTree extends Timber.Tree {
        @Override
        protected void log(int priority, String tag, String message, Throwable t) {
            // No-op
        }
    }
}
