package com.landet.landet;

import android.content.Context;
import android.support.v4.app.Fragment;

import com.landet.landet.api.Backend;
import com.landet.landet.utils.UserManager;

import javax.inject.Inject;

public abstract class BaseFragment extends Fragment {
    @Inject
    protected Backend mBackend;
    @Inject
    protected UserManager mUserManager;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        ((LandetApplication) context.getApplicationContext()).getLandetComponent().inject(this);
    }
}
