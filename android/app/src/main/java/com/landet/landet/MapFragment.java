package com.landet.landet;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.landet.landet.data.Location;
import com.landet.landet.locations.LocationModel;
import com.landet.landet.utils.ZoomableViewGroup;
import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;

import java.util.List;

import rx.functions.Action1;
import timber.log.Timber;


public class MapFragment extends BaseFragment {
    private LocationModel mLocationModel;
    private ZoomableViewGroup zoomable;
    private ImageView map;

    public MapFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mLocationModel = new LocationModel(mBackend);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        final View view = inflater.inflate(R.layout.fragment_map, container, false);
        zoomable = (ZoomableViewGroup) view.findViewById(R.id.container);
        map = (ImageView) view.findViewById(R.id.map);
        readMapData();
        return view;
    }

    private void readMapData() {

    }

    private void loadMapImage() {
        Picasso.with(getContext()).load("http://landet.herokuapp.com/map.png").into(map, new Callback() {
            @Override
            public void onSuccess() {
                addIcons();
            }

            @Override
            public void onError() {

            }
        });
    }

    private void addIcons() {
        mLocationModel.fetchLocations()
                .subscribe(new Action1<List<Location>>() {
                    @Override
                    public void call(List<Location> locations) {
                        //TODO measure width and place out icons
                        if (locations != null && !locations.isEmpty()) {
                            final Location location = locations.get(0);
                            ImageView icon = new ImageView(getContext());
                            icon.setImageResource(R.drawable.topics);
                            zoomable.addView(icon);
                        }
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to load locations");
                    }
                });
    }
}