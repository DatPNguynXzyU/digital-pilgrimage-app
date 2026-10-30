package com.example.apptungkinh

import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Bundle
import android.os.SystemClock
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.nio.charset.Charset
import java.util.UUID

class MainActivity : FlutterFragmentActivity() {
    private var nfcChannel: MethodChannel? = null
    private var pendingTag: Map<String, String>? = null
    private var lastUid: String? = null
    private var lastTapAt = 0L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        nfcChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "hanh_trinh_an_nhien/nfc_launch"
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "takePendingTag" -> {
                        val tag = pendingTag
                        pendingTag = null
                        result.success(tag)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // An activity recreation must not award a second check-in.
        if (savedInstanceState == null) {
            captureNfcIntent(intent)
        } else {
            val uid = savedInstanceState.getString("nfc.pending.uid")
            val eventId = savedInstanceState.getString("nfc.pending.eventId")
            val slug = savedInstanceState.getString("nfc.pending.slug")
            if (eventId != null && (uid != null || slug != null)) {
                pendingTag = mutableMapOf("eventId" to eventId).apply {
                    uid?.let { put("uid", it) }; slug?.let { put("slug", it) }
                }
            }
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        pendingTag?.let { tag ->
            outState.putString("nfc.pending.uid", tag["uid"])
            outState.putString("nfc.pending.eventId", tag["eventId"])
            outState.putString("nfc.pending.slug", tag["slug"])
        }
        super.onSaveInstanceState(outState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureNfcIntent(intent)
    }

    @Suppress("DEPRECATION")
    private fun captureNfcIntent(intent: Intent?) {
        if (intent == null) return
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return
        if (intent.action == Intent.ACTION_VIEW || intent.action == NfcAdapter.ACTION_NDEF_DISCOVERED) {
            val uri = intent.data
            val slug = uri?.getQueryParameter("temple")
            if (uri?.scheme == "https" && uri.host == "hanh-trinh-an-nhien-app.starryflute8194.chatgpt.site" &&
                uri.path == "/nfc/" && slug != null && slug.length <= 150 &&
                Regex("^[a-z0-9]+(?:-[a-z0-9]+)*$").matches(slug)) {
                val now = SystemClock.elapsedRealtime()
                if (lastUid == "link:$slug" && now - lastTapAt < 3000) return
                lastUid = "link:$slug"
                lastTapAt = now
                // A public link only navigates. Physical NFC is read again for check-in.
                pendingTag = mapOf("slug" to slug, "eventId" to UUID.randomUUID().toString())
                nfcChannel?.invokeMethod("tagAvailable", null)
                return
            }
        }
        if (intent.action != NfcAdapter.ACTION_NDEF_DISCOVERED) return
        try {
            val tag = intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG) ?: return
            if (tag.id.isEmpty()) return
            val messages = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
            val record = (messages?.firstOrNull() as? NdefMessage)?.records?.firstOrNull()
                ?: return
            if (!isTempleRecord(record)) return
            val uid = tag.id.joinToString("") { "%02X".format(it.toInt() and 0xFF) }
            val now = SystemClock.elapsedRealtime()
            if (uid == lastUid && now - lastTapAt < 3000) return
            lastUid = uid
            lastTapAt = now
            pendingTag = mapOf("uid" to uid, "eventId" to UUID.randomUUID().toString())
            nfcChannel?.invokeMethod("tagAvailable", null)
        } catch (_: Exception) {
            // Ignore malformed/unrelated tags; they cannot become check-in requests.
        }
    }

    private fun isTempleRecord(record: NdefRecord): Boolean {
        val payload = record.payload
        if (payload.isEmpty() || payload.size > 2048) return false
        val text = when {
            record.tnf == NdefRecord.TNF_MIME_MEDIA &&
                String(record.type, Charsets.US_ASCII) == "application/vnd.hanhtrinhannhien.temple" ->
                String(payload, Charsets.UTF_8)
            record.tnf == NdefRecord.TNF_WELL_KNOWN && record.type.contentEquals(NdefRecord.RTD_TEXT) -> {
                val flags = payload[0].toInt() and 0xFF
                val start = 1 + (flags and 0x3F)
                if (start >= payload.size) return false
                val encoding = if (flags and 0x80 == 0) Charsets.UTF_8 else Charset.forName("UTF-16")
                String(payload, start, payload.size - start, encoding)
            }
            else -> return false
        }
        if (text.trim().startsWith("TEMPLE:", ignoreCase = true)) {
            return text.trim().substringAfter(":").isNotBlank()
        }
        return JSONObject(text).optString("type") == "temple"
    }
}
