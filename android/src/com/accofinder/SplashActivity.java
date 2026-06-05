package com.accofinder;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.content.Intent;
import android.view.ViewTreeObserver;
import org.qtproject.qt.android.bindings.QtActivity;

public class SplashActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        // Set up an OnPreDrawListener to the root view
        final View content = findViewById(android.R.id.content);
        content.getViewTreeObserver().addOnPreDrawListener(
            new ViewTreeObserver.OnPreDrawListener() {
                @Override
                public boolean onPreDraw() {
                    Intent intent = new Intent(SplashActivity.this, QtActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                    startActivity(intent);

                    content.getViewTreeObserver().removeOnPreDrawListener(this);
                    finish();
                    return true;
                }
            }
        );
    }
}