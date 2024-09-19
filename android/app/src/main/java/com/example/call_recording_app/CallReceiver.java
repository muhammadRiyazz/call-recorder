package com.example.call_recording_app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.TelephonyManager;
import android.util.Log;

public class CallReceiver extends BroadcastReceiver {
    private static final String TAG = "CallReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        String state = intent.getStringExtra(TelephonyManager.EXTRA_STATE);

        if (TelephonyManager.EXTRA_STATE_OFFHOOK.equals(state)) {
            Log.d(TAG, "Call started. Starting recording...");
            Intent serviceIntent = new Intent(context, CallRecordingService.class);
            serviceIntent.putExtra("action", "start");
            context.startService(serviceIntent);
        } else if (TelephonyManager.EXTRA_STATE_IDLE.equals(state)) {
            Log.d(TAG, "Call ended. Stopping recording...");
            Intent serviceIntent = new Intent(context, CallRecordingService.class);
            serviceIntent.putExtra("action", "stop");
            context.startService(serviceIntent);
        }
    }
}
