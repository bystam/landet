package com.landet.landet.utils;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.support.annotation.NonNull;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

public class UiUtils {
    /**
     * Work-around for a background state bug present in 5.0 and 5.1. After setting and unsetting an error
     * on a TextInputLayout, the EditText will have its background stay red. This method simply resets the
     * background for the given view on these versions.
     */
    public static void resetBackgroundState(@NonNull View view) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP &&
                Build.VERSION.SDK_INT <= Build.VERSION_CODES.LOLLIPOP_MR1) {
            view.setBackground(view.getBackground().getConstantState().newDrawable());
        }
    }

    public static void hideKeyboard(View v, Activity act) {
        if (v == null || act == null) {
            return;
        }
        InputMethodManager in = (InputMethodManager) act.getSystemService(Context.INPUT_METHOD_SERVICE);
        in.hideSoftInputFromWindow(v.getApplicationWindowToken(),
                                   InputMethodManager.HIDE_NOT_ALWAYS);
    }
}
