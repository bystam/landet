package com.landet.landet.locations;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatDialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import com.landet.landet.R;
import com.landet.landet.data.Location;
import com.squareup.picasso.Picasso;

public class LocationDialogFragment extends AppCompatDialogFragment {
    public static final String ARG_LOCATION = "location";

    @NonNull
    public static LocationDialogFragment newInstance(@NonNull Location location) {
        Bundle args = new Bundle();
        args.putParcelable(ARG_LOCATION, location);
        LocationDialogFragment fragment = new LocationDialogFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Location location = getArguments().getParcelable(ARG_LOCATION);
        final View view = createView(R.layout.dialog_location, location);
        String title = location != null ? location.getName() : "Location";

        return new AlertDialog.Builder(getContext())
                .setTitle(title)
                .setView(view)
                .create();
    }

    private View createView(int layout, Location location) {
        final View view = LayoutInflater.from(getContext()).inflate(layout, null, false);
        final ImageView image = (ImageView) view.findViewById(R.id.image);
        final Button buttonClose = (Button) view.findViewById(R.id.button_close);
        if (location != null) {
            Picasso.with(getContext()).load(location.getImageUrl()).placeholder(R.drawable.location_image_placeholder).into(image);
        }
        buttonClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getDialog().dismiss();
            }
        });
        return view;
    }
}
