package com.landet.landet;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.landet.landet.data.Location;
import com.landet.landet.data.MapContent;
import com.landet.landet.data.MapLocation;
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
    private MapContent mMapContent;

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
        mLocationModel.fetchMapContent()
                .subscribe(new Action1<MapContent>() {
                    @Override
                    public void call(MapContent mapContent) {
                        mMapContent = mapContent;
                        loadMapImage(mapContent);
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d(throwable, "Failed to load map content");
                    }
                });
    }

    private void loadMapImage(MapContent mapContent) {
        Picasso.with(getContext()).load(mapContent.getUrl()).into(map, new Callback() {
            @Override
            public void onSuccess() {
                addIcons();
            }

            @Override
            public void onError() {
                Timber.d("Failed to load map image");
            }
        });
    }

    private void addIcons() {
        mLocationModel.fetchLocations()
                .subscribe(new Action1<List<Location>>() {
                    @Override
                    public void call(List<Location> locations) {
                        if (locations != null && !locations.isEmpty() && mMapContent != null) {
                            for (Location location : locations) {
                                for (MapLocation mapLocation : mMapContent.getLocations()) {
                                    if (mapLocation.getId().equals(location.getEnumId())) {
                                        ImageView icon = new ImageView(getContext());
                                        icon.setImageResource(getIconDrawable(location));
                                        icon.setAdjustViewBounds(true);
                                        icon.setX(mapLocation.getX() - 100);
                                        icon.setY(mapLocation.getY() - 100);
                                        icon.setMaxWidth(200);
                                        icon.setMaxHeight(200);
                                        icon.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                                        zoomable.addView(icon);
                                    }
                                }
                            }
                        }
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to load locations");
                    }
                });
    }

    private int getIconDrawable(Location location) {
        switch (location.getEnumId()) {
            case "SAUNA":
            case "HOUSE":
            case "NEW_GUESTHOUSE":
            case "OLD_GUESTHOUSE":
            case "TOOLSHED":
                return R.drawable.house;
            case "FRONT_LAWN":
            case "BACK_LAWN":
            case "OUTSIDE_TABLEGROUP":
            default:
                return R.drawable.landmark;
        }
    }
}