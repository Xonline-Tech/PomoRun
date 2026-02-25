package com.example.pomorun

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private var toneGenerator: ToneGenerator? = null
  private val handler = Handler(Looper.getMainLooper())

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    if (toneGenerator == null) {
      toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, 80)
    }

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pomorun/tick")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "tick" -> {
            playTone(40)
            result.success(null)
          }
          "accent" -> {
            playTone(45)
            handler.postDelayed({ playTone(45) }, 70)
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun playTone(durationMs: Int) {
    try {
      toneGenerator?.startTone(ToneGenerator.TONE_PROP_BEEP, durationMs)
    } catch (_: Exception) {
    }
  }

  override fun onDestroy() {
    try {
      toneGenerator?.release()
    } catch (_: Exception) {
    }
    toneGenerator = null
    super.onDestroy()
  }
}
