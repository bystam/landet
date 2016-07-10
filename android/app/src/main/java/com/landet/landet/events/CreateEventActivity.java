package com.landet.landet.events;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.TimePickerDialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.ActionBar;
import android.text.format.DateFormat;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.Toast;

import com.landet.landet.BaseActivity;
import com.landet.landet.R;
import com.landet.landet.data.Event;
import com.landet.landet.data.Location;
import com.landet.landet.locations.LocationModel;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;

import java.util.Calendar;
import java.util.List;

import rx.Subscription;
import rx.functions.Action1;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;

public class CreateEventActivity extends BaseActivity {
    private EventModel mModel;
    private LocationModel mLocationModel;
    private CompositeSubscription mCompositeSubscription;
    private Spinner spinner;
    private Location location;
    private DateTime dateTime;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_event);

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }

        mModel = new EventModel(mBackend);
        mCompositeSubscription = new CompositeSubscription();
        mLocationModel = new LocationModel(mBackend);
        fetchLocations();

        spinner = (Spinner) findViewById(R.id.spinner);

        final EditText title = (EditText) findViewById(R.id.title);
        final EditText body = (EditText) findViewById(R.id.body);
        Button button = (Button) findViewById(R.id.button);

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Event event = new Event(
                        title.getText().toString(),
                        body.getText().toString(),
                        dateTime,
                        location);
                if (validateEvent(event)) {
                    createEvent(event);
                }
            }

            private boolean validateEvent(Event event) { // TODO: Make prettier: setting errors on EditText and such.
                if (event.getTitle() == null || event.getTitle().equals("")) {
                    Toast.makeText(CreateEventActivity.this, "Error: Wrong or empty title", Toast.LENGTH_SHORT).show();
                    return false;
                }
                if (event.getBody() == null || event.getBody().equals("")) {
                    Toast.makeText(CreateEventActivity.this, "Error: Wrong or empty description", Toast.LENGTH_SHORT).show();
                    return false;
                }
                if (event.getEventTime() == null) {
                    Toast.makeText(CreateEventActivity.this, "Error: No time picked", Toast.LENGTH_SHORT).show();
                    return false;
                }
                if (event.getLocation() == null) {
                    Toast.makeText(CreateEventActivity.this, "Error: No location picked", Toast.LENGTH_SHORT).show();
                    return false;
                }
                return true;
            }
        });
    }

    public void showDatePickerDialog(final View view) {
        DatePickerFragment newFragment = new DatePickerFragment();
        newFragment.setOnDateSetListener(new DatePickerFragment.OnDateSetListener() {
            @Override
            public void onDateSet(int year, int month, int day) {
                if (year == 2016 && month == 7 && day >= 14 && day <= 17) {
                    showTimePickerDialog(year, month, day);
                } else {
                    Toast.makeText(CreateEventActivity.this, "Choose a relevant date, stupid (July 14-17)", Toast.LENGTH_SHORT).show();
                    showDatePickerDialog(view);
                }
            }
        });
        newFragment.show(getSupportFragmentManager(), "datePicker");
    }

    public void showTimePickerDialog(final int year, final int month, final int day) {
        TimePickerFragment newFragment = new TimePickerFragment();
        newFragment.setOnTimeSetListener(new TimePickerFragment.OnTimeSetListener() {
            @Override
            public void onTimeSet(int hourOfDay, int minute) {
                dateTime = new DateTime(year, month, day, hourOfDay, minute);

                TextView time = (TextView) findViewById(R.id.time);
                time.setText(DateTimeFormat.forPattern("HH:mm").print(dateTime));
                TextView date = (TextView) findViewById(R.id.date);
                date.setText(DateTimeFormat.forPattern("MMM dd").print(dateTime));
            }
        });
        newFragment.show(getSupportFragmentManager(), "timePicker");
    }

    private void fetchLocations() {
        final Subscription subscription = mLocationModel.fetchLocations()
                .subscribe(new Action1<List<Location>>() {
                    @Override
                    public void call(List<Location> locations) {
                        Timber.d("Fetched locations: %s", locations);
                        ArrayAdapter<Location> arrayAdapter = new ArrayAdapter<>(CreateEventActivity.this, R.layout.location_spinner, locations);
                        spinner.setAdapter(arrayAdapter);
                        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                                location = (Location) spinner.getItemAtPosition(i);
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> adapterView) { }
                        });
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to fetch locations");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    private void createEvent(@NonNull Event event) {
        final Subscription subscription = mModel.createEvent(event)
                .subscribe(new Action1<Event>() {
                    @Override
                    public void call(Event event) {
                        Timber.d("Created event: %s", event.getTitle());
                        Intent intent = getIntent();
                        setResult(RESULT_OK, intent);
                        finish();
                    }
                }, new Action1<Throwable>() {
                    @Override
                    public void call(Throwable throwable) {
                        Timber.d("Failed to create event");
                    }
                });
        mCompositeSubscription.add(subscription);
    }

    public static class DatePickerFragment extends DialogFragment
            implements DatePickerDialog.OnDateSetListener {

        public OnDateSetListener onDateSetListener;

        public interface OnDateSetListener {
            void onDateSet(int year, int month, int day);
        }

        public void setOnDateSetListener(OnDateSetListener onDateSetListener) {
            this.onDateSetListener = onDateSetListener;
        }

        @NonNull
        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the current date as the default date in the picker
            final Calendar c = Calendar.getInstance();
            int year = c.get(Calendar.YEAR);
            int month = c.get(Calendar.MONTH);
            int day = c.get(Calendar.DAY_OF_MONTH);

            // Create a new instance of DatePickerDialog and return it
            return new DatePickerDialog(getActivity(), this, year, month, day);
        }

        public void onDateSet(DatePicker view, int year, int month, int day) {
            onDateSetListener.onDateSet(year, month + 1, day);
        }
    }

    public static class TimePickerFragment extends DialogFragment
            implements TimePickerDialog.OnTimeSetListener {

        public OnTimeSetListener onTimeSetListener;

        public interface OnTimeSetListener {
            void onTimeSet(int hourOfDay, int minute);
        }

        public void setOnTimeSetListener(OnTimeSetListener onTimeSetListener) {
            this.onTimeSetListener = onTimeSetListener;
        }

        @NonNull
        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the current time as the default values for the picker
            final Calendar c = Calendar.getInstance();
            int hour = c.get(Calendar.HOUR_OF_DAY);
            int minute = c.get(Calendar.MINUTE);

            // Create a new instance of TimePickerDialog and return it
            return new TimePickerDialog(getActivity(), this, hour, minute,
                    DateFormat.is24HourFormat(getActivity()));
        }

        public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
            onTimeSetListener.onTimeSet(hourOfDay, minute);
        }
    }
}
