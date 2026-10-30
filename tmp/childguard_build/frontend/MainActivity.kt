package vn.edu.hutech.phamnguyentuandat_2380614580

import android.Manifest
import android.content.pm.PackageManager
import android.hardware.fingerprint.FingerprintManager
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FingerprintManager is deliberately used to exclude face/PIN authentication.
// All application screens and business logic are Flutter/Dart.
@Suppress("DEPRECATION")
class MainActivity : FlutterActivity() {
    private var cancellation: CancellationSignal? = null
    private var pending: MethodChannel.Result? = null
    private val handler = Handler(Looper.getMainLooper())
    private val timeout = Runnable { finishAuth(false) }
    private fun manager() = getSystemService(FingerprintManager::class.java)
    private fun available(): Boolean =
        checkSelfPermission(Manifest.permission.USE_FINGERPRINT) == PackageManager.PERMISSION_GRANTED &&
        manager()?.isHardwareDetected == true && manager()?.hasEnrolledFingerprints() == true

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "childguard/fingerprint")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "available" -> result.success(available())
                    "cancel" -> { finishAuth(false); result.success(null) }
                    "authenticate" -> {
                        if (!available()) { result.error("UNAVAILABLE", "Không có vân tay đã đăng ký", null) }
                        else if (pending != null) { result.error("BUSY", "Đang xác thực", null) }
                        else {
                            pending = result
                            cancellation = CancellationSignal()
                            handler.postDelayed(timeout, 30000)
                            try {
                                manager().authenticate(null, cancellation, 0,
                                    object : FingerprintManager.AuthenticationCallback() {
                                        override fun onAuthenticationSucceeded(r: FingerprintManager.AuthenticationResult) { finishAuth(true) }
                                        override fun onAuthenticationError(code: Int, message: CharSequence) { finishAuth(false) }
                                        override fun onAuthenticationFailed() { /* Allow retry until timeout. */ }
                                    }, handler)
                            } catch (e: Exception) { finishAuth(false) }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
    private fun finishAuth(success: Boolean) {
        val result = pending
        pending = null
        handler.removeCallbacks(timeout)
        val signal = cancellation
        cancellation = null
        signal?.cancel()
        result?.success(success)
    }
    override fun onPause() { finishAuth(false); super.onPause() }
    override fun onDestroy() { finishAuth(false); super.onDestroy() }
}
