package com.landet.landet.user;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.TextInputLayout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.TextView;

import com.landet.landet.BaseFragment;
import com.landet.landet.R;
import com.landet.landet.utils.UiUtils;

import timber.log.Timber;

public class RegisterFragment extends BaseFragment {
    private static final String STATE_HAS_VALIDATED = "has_validated";

    private ProgressDialog mProgressDialog;
    private TextInputLayout mNameLayout;
    private TextInputLayout mUsernameLayout;
    private TextInputLayout mPasswordLayout;
    private TextInputLayout mConfirmPasswordLayout;
    private EditText mName;
    private EditText mUsername;
    private EditText mPassword;
    private EditText mConfirmPassword;
    private TextView mErrorLabel;
    private View mRegisterButton;
    private boolean mUsernameTouched;

    private boolean mHasValidated;

    @Nullable
    @Override
    public View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_register, container, false);
        mNameLayout = (TextInputLayout) root.findViewById(R.id.input_layout_name);
        mUsernameLayout = (TextInputLayout) root.findViewById(R.id.input_layout_username);
        mPasswordLayout = (TextInputLayout) root.findViewById(R.id.input_layout_password);
        mConfirmPasswordLayout = (TextInputLayout) root.findViewById(R.id.input_layout_confirm_password);

        mUsernameTouched = false;

        mName = (EditText) root.findViewById(R.id.input_name);
        mUsername = (EditText) root.findViewById(R.id.input_username);
        mPassword = (EditText) root.findViewById(R.id.input_password);
        mConfirmPassword = (EditText) root.findViewById(R.id.input_confirm_password);
        mUsernameLayout.findViewById(R.id.input_username).setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (!hasFocus) {
                    mUsernameTouched = true;
                    validateField(mUsername, true);
                }
            }
        });

        mErrorLabel = (TextView) root.findViewById(R.id.error);
        mRegisterButton = root.findViewById(R.id.button_register);
        mRegisterButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                if (validateData(true)) {
                    String name = mName.getText().toString().trim();
                    String username = mUsername.getText().toString().trim();
                    String password = mPassword.getText().toString();
                    UiUtils.hideKeyboard(mName, getActivity());
                    showProgressDialog();
                    ((LoginOrRegisterActivity) getActivity()).registerUser(username, password, name);
                }
            }
        });
        return root;
    }

    @Override
    public void onViewStateRestored(@Nullable Bundle savedInstanceState) {
        super.onViewStateRestored(savedInstanceState);
        if (savedInstanceState != null && savedInstanceState.getBoolean(STATE_HAS_VALIDATED)) {
            validateData(false);
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putBoolean(STATE_HAS_VALIDATED, mHasValidated);
    }

    private boolean validateData(boolean showError) {
        mHasValidated = true;
        boolean valid;
        valid = validateField(mName, showError);
        valid &= validateField(mUsername, showError);
        valid &= validateField(mPassword, showError);
        valid &= validateField(mConfirmPassword, showError);
        mRegisterButton.setEnabled(valid);
        return valid;
    }

    /**
     * Called when a field changes, and possibly when it loses focus.
     * @param showError if true, also adds an error message to the field
     */
    private boolean validateField(View field, boolean showError) {
        if (field == mName) {
            if (mName.getText().toString().trim().length() == 0) {
                if (showError) {
                    mNameLayout.setError(getString(R.string.error_no_name));
                }
                return false;
            } else {
                mNameLayout.setError(null);
                mNameLayout.setErrorEnabled(false);
                UiUtils.resetBackgroundState(mName);
            }
        }
        if (field == mUsername) {
            final String username = mUsername.getText().toString().trim();
            if (mUsernameTouched && (username.length() == 0)) {
                if (showError) {
                    mUsernameLayout.setError(getString(R.string.error_invalid_username));
                }
                return false;
            } else {
                mUsernameLayout.setError(null);
                mUsernameLayout.setErrorEnabled(false);
                UiUtils.resetBackgroundState(mUsername);
            }
        }
        if (field == mPassword || field == mConfirmPassword) {
            if (mPassword.getText().toString().length() < 1) {
                if (showError && mPassword.getText().length() > 0) {
                    mPasswordLayout.setError(getString(R.string.error_invalid_password));
                }
                return false;
            } else {
                mPasswordLayout.setError(null);
                mPasswordLayout.setErrorEnabled(false);
                UiUtils.resetBackgroundState(mPassword);
            }
        }
        if (field == mConfirmPassword || field == mPassword) {
            if (!mConfirmPassword.getText().toString().equals(mPassword.getText().toString())) {
                if (showError && mConfirmPassword.getText().length() > 0) {
                    mConfirmPasswordLayout.setError(getString(R.string.error_passwords_dont_match));
                }
                return false;
            } else {
                mConfirmPasswordLayout.setError(null);
                mConfirmPasswordLayout.setErrorEnabled(false);
                UiUtils.resetBackgroundState(mConfirmPassword);
            }
        }
        return true;
    }

    private void showProgressDialog() {
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog(getActivity());
            mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            mProgressDialog.setMessage(getString(R.string.registering));
            mProgressDialog.setCancelable(false);
            mProgressDialog.show();
        }
    }

    public void hideProgressDialog() {
        if (mProgressDialog != null) {
            mProgressDialog.dismiss();
            mProgressDialog = null;
        }
    }

    public void onRegisterSuccess() {
        hideProgressDialog();
    }

    public void onRegisterFailed(Throwable e) {
        hideProgressDialog();
        mErrorLabel.setText(R.string.register_failed);
        mErrorLabel.setVisibility(View.VISIBLE);
        Timber.d(e, "Register failed");
    }
}
