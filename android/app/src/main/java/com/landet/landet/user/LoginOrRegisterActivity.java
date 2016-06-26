package com.landet.landet.user;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.MenuItem;
import android.view.ViewGroup;

import com.landet.landet.BaseActivity;
import com.landet.landet.R;

import rx.Observer;
import rx.Subscription;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action0;
import rx.schedulers.Schedulers;
import timber.log.Timber;

public class LoginOrRegisterActivity extends BaseActivity {
    private static final String EXTRA_SHOW_REGISTER = "EXTRA_SHOW_REGISTER";
    private static final String STATE_SELECTED_TAB = "STATE_SELECTED_TAB";

    private boolean mLoginAttempted;
    private boolean mRegistrationAttempted;
    private TabLayout mTabLayout;
    private LoginOrRegisterFragmentPagerAdapter mTabAdapter;
    private Subscription mLoginSubscription;
    private Subscription mRegistrationSubscription;

    /**
     * Returns an Intent to show this activity, with either the login form or register form shown.
     * @param showRegister true if the registration form should be shown, false to show login form
     */
    @NonNull
    public static Intent buildIntent(@NonNull Context context, boolean showRegister) {
        return new Intent(context, LoginOrRegisterActivity.class)
                .putExtra(EXTRA_SHOW_REGISTER, showRegister);
    }

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_or_register);

        mTabAdapter = new LoginOrRegisterFragmentPagerAdapter(getSupportFragmentManager(), LoginOrRegisterActivity.this);

        final ViewPager viewPager = (ViewPager) findViewById(R.id.content);
        if (viewPager == null) {
            throw new RuntimeException("No view pager");
        }
        viewPager.setAdapter(mTabAdapter);

        mTabLayout = (TabLayout) findViewById(R.id.tabs);
        if (mTabLayout == null) {
            throw new RuntimeException("No tab layout");
        }
        mTabLayout.setupWithViewPager(viewPager);

        int selectedTab = getIntent().getBooleanExtra(EXTRA_SHOW_REGISTER, false) ?
                LoginOrRegisterFragmentPagerAdapter.TAB_REGISTER :
                LoginOrRegisterFragmentPagerAdapter.TAB_LOGIN;
        if (savedInstanceState != null) {
            selectedTab = savedInstanceState.getInt(STATE_SELECTED_TAB);
        }

        viewPager.setCurrentItem(selectedTab);
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mLoginSubscription != null && !mLoginSubscription.isUnsubscribed()) {
            mLoginSubscription.unsubscribe();
            mLoginSubscription = null;
        }
        if (mRegistrationSubscription != null && !mRegistrationSubscription.isUnsubscribed()) {
            mRegistrationSubscription.unsubscribe();
            mRegistrationSubscription = null;
        }
    }

    @Override
    protected void onSaveInstanceState(final Bundle outState) {
        outState.putInt(STATE_SELECTED_TAB, mTabLayout.getSelectedTabPosition());
        super.onSaveInstanceState(outState);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void loginUser(String username, String password) {
        if (!mLoginAttempted && !mRegistrationAttempted) {
            mLoginAttempted = true;
            mLoginSubscription = mUserManager.login(username, password)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .doOnUnsubscribe(new Action0() {
                        @Override
                        public void call() {
                            Timber.d("Unsubscribe login");
                            LoginFragment loginFragment = mTabAdapter.getLoginFragment();
                            if (loginFragment != null) {
                                loginFragment.hideProgressDialog();
                            }
                            mLoginAttempted = false;
                        }
                    })
                    .subscribe(new Observer<Void>() {
                        @Override
                        public void onCompleted() {
                            mLoginAttempted = false;
                            onLoginSuccess();
                        }

                        @Override
                        public void onError(final Throwable e) {
                            mLoginAttempted = false;
                            onLoginFailed(e);
                        }

                        @Override
                        public void onNext(final Void aVoid) {
                        }
                    });
        }
    }

    public void registerUser(String username, String password, String name) {
        if (!mRegistrationAttempted && !mLoginAttempted) {
            mRegistrationAttempted = true;
            mRegistrationSubscription = mUserManager.register(username, password, name)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .doOnUnsubscribe(new Action0() {
                        @Override
                        public void call() {
                            Timber.d("Unsubscribe register");
                            RegisterFragment registerFragment = mTabAdapter.getRegisterFragment();
                            if (registerFragment != null) {
                                registerFragment.hideProgressDialog();
                            }
                            mRegistrationAttempted = false;
                        }
                    })
                    .subscribe(new Observer<Void>() {
                        @Override
                        public void onCompleted() {
                            mRegistrationAttempted = false;
                            onRegisterSuccess();
                        }

                        @Override
                        public void onError(final Throwable e) {
                            mRegistrationAttempted = false;
                            onRegisterFailed(e);
                        }

                        @Override
                        public void onNext(final Void aVoid) {
                        }
                    });
        }
    }

    private void onLoginSuccess() {
        LoginFragment loginFragment = mTabAdapter.getLoginFragment();
        if (loginFragment != null) {
            loginFragment.onLoginSuccess();
        }
        setResult(RESULT_OK);
        finish();
    }

    private void onLoginFailed(Throwable e) {
        LoginFragment loginFragment = mTabAdapter.getLoginFragment();
        if (loginFragment != null) {
            loginFragment.onLoginFailed(e);
        }
    }

    private void onRegisterSuccess() {
        RegisterFragment registerFragment = mTabAdapter.getRegisterFragment();
        if (registerFragment != null) {
            registerFragment.onRegisterSuccess();
        }
        setResult(RESULT_OK);
        finish();
    }

    private void onRegisterFailed(Throwable e) {
        RegisterFragment registerFragment = mTabAdapter.getRegisterFragment();
        if (registerFragment != null) {
            registerFragment.onRegisterFailed(e);
        }
    }

    public static class LoginOrRegisterFragmentPagerAdapter extends FragmentPagerAdapter {
        public static final int TAB_LOGIN = 0;
        public static final int TAB_REGISTER = 1;
        private String[] tabTitles;
        private LoginFragment mLoginFragment;
        private RegisterFragment mRegisterFragment;

        public LoginOrRegisterFragmentPagerAdapter(FragmentManager fm, Context context) {
            super(fm);
            this.tabTitles = new String[] { context.getString(R.string.title_login), context.getString(R.string.title_register) };
        }

        @Override
        public int getCount() {
            return 2;
        }

        @Override
        public Object instantiateItem(ViewGroup container, int position) {
            if (position == TAB_LOGIN) {
                mLoginFragment = (LoginFragment) super.instantiateItem(container, position);
                return mLoginFragment;
            } else if (position == TAB_REGISTER) {
                mRegisterFragment = (RegisterFragment) super.instantiateItem(container, position);
                return mRegisterFragment;
            }

            return super.instantiateItem(container, position);
        }

        @Override
        public Fragment getItem(int position) {
            if (position == TAB_LOGIN) {
                return new LoginFragment();
            } else if (position == TAB_REGISTER) {
                return new RegisterFragment();
            }
            throw new IllegalArgumentException("No fragment at position " + position);
        }

        @Nullable
        public LoginFragment getLoginFragment() {
            return mLoginFragment;
        }

        @Nullable
        public RegisterFragment getRegisterFragment() {
            return mRegisterFragment;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return tabTitles[position];
        }
    }
}
