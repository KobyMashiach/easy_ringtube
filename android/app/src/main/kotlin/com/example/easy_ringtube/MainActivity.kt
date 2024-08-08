package com.example.easy_ringtube

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.ContactsContract
import android.provider.MediaStore
import android.provider.Settings
import android.media.RingtoneManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.io.File
import android.content.pm.PackageManager // Add this import

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example/ringtone"
    private val CONTACT_PICK_REQUEST_CODE = 1
    private val REQUEST_CODE_WRITE_SETTINGS = 200
    private val REQUEST_CODE_WRITE_CONTACTS = 300
    private lateinit var ringtoneFilePath: String

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setRingtone" -> {
                        ringtoneFilePath = call.argument<String>("filePath") ?: ""
                        if (checkWriteSettingsPermission()) {
                            setRingtone(ringtoneFilePath)
                            result.success(null)
                        } else {
                            requestWriteSettingsPermission()
                            result.error("PERMISSION_DENIED", "Write settings permission is required.", null)
                        }
                    }
                    "selectContactAndSetRingtone" -> {
                        ringtoneFilePath = call.argument<String>("filePath") ?: ""
                        if (checkWriteSettingsPermission()) {
                            if (checkWriteContactsPermission()) {
                                selectContactAndSetRingtone()
                            } else {
                                requestWriteContactsPermission()
                            }
                            result.success(null)
                        } else {
                            requestWriteSettingsPermission()
                            result.error("PERMISSION_DENIED", "Write settings permission is required.", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun checkWriteSettingsPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.System.canWrite(this)
        } else {
            true // Permission is automatically granted on devices below API 23
        }
    }

    private fun requestWriteSettingsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivityForResult(intent, REQUEST_CODE_WRITE_SETTINGS)
        }
    }

    private fun checkWriteContactsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(this, android.Manifest.permission.WRITE_CONTACTS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestWriteContactsPermission() {
        ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.WRITE_CONTACTS), REQUEST_CODE_WRITE_CONTACTS)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_WRITE_CONTACTS) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Retry the contact-related operation
                selectContactAndSetRingtone()
            } else {
                // Handle the case where the permission is denied
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_WRITE_SETTINGS) {
            // Re-check permission after returning from settings
            if (checkWriteSettingsPermission()) {
                // Permission granted, retry the operation if necessary
            } else {
                // Permission denied, handle accordingly
            }
        }
        if (requestCode == CONTACT_PICK_REQUEST_CODE && resultCode == RESULT_OK) {
            data?.data?.let { contactUri ->
                val contactId = contactUri.lastPathSegment?.toLong()
                contactId?.let { setRingtoneForContact(it) }
            }
        }
    }

    private fun setRingtone(filePath: String) {
        val file = File(filePath)
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DATA, file.absolutePath)
            put(MediaStore.MediaColumns.MIME_TYPE, "audio/mp3")
            put(MediaStore.Audio.Media.IS_RINGTONE, true)
        }
        val uri = contentResolver.insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)
        if (uri != null) {
            RingtoneManager.setActualDefaultRingtoneUri(this, RingtoneManager.TYPE_RINGTONE, uri)
        }
    }

    private fun selectContactAndSetRingtone() {
        val intent = Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI)
        startActivityForResult(intent, CONTACT_PICK_REQUEST_CODE)
    }

    private fun setRingtoneForContact(contactId: Long) {
        val file = File(ringtoneFilePath)
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DATA, file.absolutePath)
            put(MediaStore.MediaColumns.MIME_TYPE, "audio/mp3")
            put(MediaStore.Audio.Media.IS_RINGTONE, true)
        }
        val uri = contentResolver.insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)

        val contactUri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, contactId.toString())
        val contactValues = ContentValues().apply {
            put(ContactsContract.Contacts.CUSTOM_RINGTONE, uri.toString())
        }
        contentResolver.update(contactUri, contactValues, null, null)
    }
}
