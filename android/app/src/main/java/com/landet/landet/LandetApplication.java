package com.landet.landet;

import android.app.Application;

public class LandetApplication extends Application {
    private LandetComponent mLandetComponent;

    @Override
    public void onCreate() {
        super.onCreate();
        LandetModule landetModule = new LandetModule(this);
        mLandetComponent = DaggerLandetComponent.builder()
                .landetModule(landetModule)
                .build();
    }

    public LandetComponent getLandetComponent() {
        return mLandetComponent;
    }
}
