package com.example.speakhands_mobile

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.speakhands/landmarks"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getLandmarks") {
                // ⚠️ Esto es un valor de prueba, simula landmarks reales
                val landmarks = List(63) { Math.random() } // 21 puntos * 3 (x, y, z)
                result.success(landmarks)
            } else {
                result.notImplemented()
            }
        }
    }
}
