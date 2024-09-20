package com.example.call_recording_app;

import android.app.Service;
import android.content.Intent;
import android.media.MediaRecorder;
import android.os.Environment;
import android.os.IBinder;
import android.util.Log;

import java.io.File;
import java.io.IOException;

public class CallRecordingService extends Service {
    private static final String TAG = "CallRecordingService";
    private MediaRecorder recorder = null;
    private File audioFile;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        String action = intent.getStringExtra("action");
        if ("start".equals(action)) {
            startRecording();
        } else if ("stop".equals(action)) {
            stopRecording();
        }
        return START_NOT_STICKY;
    }

    private void startRecording() {
        try {
            // Create a unique file name with timestamp
            String timestamp = String.valueOf(System.currentTimeMillis());
            File publicDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "Recordings");
            if (!publicDir.exists()) {
                publicDir.mkdirs(); // Create the directory if it doesn't exist
            }
            audioFile = new File(publicDir, "recorded_call_" + timestamp + ".3gp");

            recorder = new MediaRecorder();
            recorder.setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION);
            recorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
            recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
            recorder.setOutputFile(audioFile.getAbsolutePath());
            recorder.prepare();
            recorder.start();
        } catch (IOException e) {
            Log.e(TAG, "Error during recording", e);
        }
    }

    private void stopRecording() {
        if (recorder != null) {
            recorder.stop();
            recorder.release();
            recorder = null;
            Log.d(TAG, "Recording stopped. File saved at: " + audioFile.getAbsolutePath());
        }
    }
}
