package com.landet.landet;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.TextView;

import com.landet.landet.events.EventsFragment;
import com.landet.landet.user.LoginOrRegisterActivity;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends BaseActivity {
    private static final int REQUEST_CODE_LOGIN = 1;

    private Toolbar toolbar;
    private TabLayout tabLayout;
    private ViewPager viewPager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(false);

        viewPager = (ViewPager) findViewById(R.id.viewpager);
        setupViewPager(viewPager);

        tabLayout = (TabLayout) findViewById(R.id.tabs);
        tabLayout.setupWithViewPager(viewPager);
        setupTabIcons();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.user_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.logout:
                mUserManager.logout();
                openLoginActivityIfLoggedOut();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        openLoginActivityIfLoggedOut();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE_LOGIN:
                if (resultCode != RESULT_OK) {
                    finish();
                }
                break;
            default:
                super.onActivityResult(requestCode, resultCode, data);
        }
    }

    private void openLoginActivityIfLoggedOut() {
        if (!mUserManager.isLoggedIn()) {
            startActivityForResult(LoginOrRegisterActivity.buildIntent(this, true), REQUEST_CODE_LOGIN);
        }
    }

    private void setupTabIcons() {
        TextView eventsTab = (TextView) LayoutInflater.from(this).inflate(R.layout.custom_tab, null);
        eventsTab.setText("Events");
        eventsTab.setCompoundDrawablesWithIntrinsicBounds(null, scaleTabIcon(R.drawable.events), null, null);
        tabLayout.getTabAt(0).setCustomView(eventsTab);

        TextView topicsTab = (TextView) LayoutInflater.from(this).inflate(R.layout.custom_tab, null);
        topicsTab.setText("Topics");
        eventsTab.setCompoundDrawablesWithIntrinsicBounds(null, scaleTabIcon(R.drawable.topics), null, null);
        tabLayout.getTabAt(1).setCustomView(topicsTab);

        TextView mapTab = (TextView) LayoutInflater.from(this).inflate(R.layout.custom_tab, null);
        mapTab.setText("Map");
        eventsTab.setCompoundDrawablesWithIntrinsicBounds(null, scaleTabIcon(R.drawable.map), null, null);
        tabLayout.getTabAt(2).setCustomView(mapTab);
    }

    private Drawable scaleTabIcon(int icon) {
        Bitmap original = BitmapFactory.decodeResource(getResources(), icon);
        Bitmap b = Bitmap.createScaledBitmap(original, 50, 50, false);
        return new BitmapDrawable(getResources(), b);
    }

    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());
        adapter.addFrag(new EventsFragment(), "EVENTS");
        adapter.addFrag(new TopicsFragment(), "TOPICS");
        adapter.addFrag(new MapFragment(), "MAP");
        viewPager.setAdapter(adapter);
    }

    class ViewPagerAdapter extends FragmentPagerAdapter {
        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {
            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFrag(Fragment fragment, String title) {
            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mFragmentTitleList.get(position);
        }
    }
}
