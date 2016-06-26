package com.landet.landet.user;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.TextInputLayout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.landet.landet.BaseFragment;
import com.landet.landet.R;
import com.landet.landet.utils.UiUtils;

import timber.log.Timber;

public class LoginFragment extends BaseFragment {
    private static final String STATE_HAS_VALIDATED = "has_validated";

    private TextInputLayout mEmailLayout;
    private TextInputLayout mPasswordLayout;
    private TextView mEmailField;
    private TextView mPasswordField;
    private ProgressDialog mProgressDialog;
    private TextView mError;

    private View mLoginButton;

    private boolean mHasValidated;

    @Nullable
    @Override
    public View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
        final View root = inflater.inflate(R.layout.fragment_login, container, false);
        mEmailLayout = (TextInputLayout) root.findViewById(R.id.input_layout_username);
        mPasswordLayout = (TextInputLayout) root.findViewById(R.id.input_layout_password);
        mEmailField = (TextView) root.findViewById(R.id.input_username);
        mPasswordField = (TextView) root.findViewById(R.id.input_password);
        mError = (TextView) root.findViewById(R.id.error);

        mLoginButton = root.findViewById(R.id.button_login);
        mLoginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                if (validateInput()) {
                    UiUtils.hideKeyboard(mPasswordField, getActivity());
                    showProgressDialog(getString(R.string.logging_in));
                    ((LoginOrRegisterActivity) getActivity()).loginUser(mEmailField.getText().toString(), mPasswordField.getText().toString());
                }
            }
        });
        return root;
    }

    @Override
    public void onViewStateRestored(@Nullable Bundle savedInstanceState) {
        super.onViewStateRestored(savedInstanceState);
        if (savedInstanceState != null) {
            if (savedInstanceState.getBoolean(STATE_HAS_VALIDATED)) {
                validateInput();
            }
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putBoolean(STATE_HAS_VALIDATED, mHasValidated);
    }

    public void onLoginSuccess() {
        hideProgressDialog();
    }

    public void onLoginFailed(Throwable e) {
        hideProgressDialog();
        mError.setText(R.string.login_failed);
        mError.setVisibility(View.VISIBLE);
        Timber.d(e, "Login failed");
    }

    private boolean validateInput() {
        mHasValidated = true;
        boolean valid = true;
        if (mEmailField.getText().toString().trim().length() == 0) {
            mEmailLayout.setError(getString(R.string.error_invalid_username));
            valid = false;
        } else {
            mEmailLayout.setError(null);
            mEmailLayout.setErrorEnabled(false);
            UiUtils.resetBackgroundState(mEmailField);
        }
        if (mPasswordField.getText().toString().length() == 0) {
            mPasswordLayout.setError(getString(R.string.error_no_password));
            valid = false;
        } else {
            mPasswordLayout.setError(null);
            mPasswordLayout.setErrorEnabled(false);
            UiUtils.resetBackgroundState(mPasswordField);
        }
        mError.setVisibility(View.GONE);
        mLoginButton.setEnabled(valid);
        return valid;
    }

    public void showProgressDialog(String message) {
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog(getActivity());
            mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            mProgressDialog.setMessage(message);
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
}
