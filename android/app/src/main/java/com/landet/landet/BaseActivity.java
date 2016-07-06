package com.landet.landet;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;

import com.landet.landet.api.Backend;
import com.landet.landet.utils.UserManager;

import javax.inject.Inject;

public class BaseActivity extends AppCompatActivity {
    @Inject
    protected Backend mBackend;
    @Inject
    protected UserManager mUserManager;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ((LandetApplication) getApplication()).getLandetComponent().inject(this);
    }
}
