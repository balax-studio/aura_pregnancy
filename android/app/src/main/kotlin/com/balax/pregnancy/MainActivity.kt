package com.balax.pregnancy

import android.content.ContentValues
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.balaxstudio.aura/gallery"
    private var lastSavedVideoUri: Uri? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImageToGallery" -> {
                    val imageBytes = call.argument<ByteArray>("imageBytes")
                    val fileNamePrefix = call.argument<String>("fileNamePrefix") ?: "Aura_Pregnancy"

                    if (imageBytes == null) {
                        result.error("INVALID_ARGUMENT", "Image bytes cannot be null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val success = saveImageToMediaStore(imageBytes, fileNamePrefix)
                        result.success(success)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.localizedMessage, null)
                    }
                }
                "saveVideoToGallery" -> {
                    val videoBytes = call.argument<ByteArray>("videoBytes")
                    val fileNamePrefix = call.argument<String>("fileNamePrefix") ?: "Aura_Yolculuk"

                    if (videoBytes == null) {
                        result.error("INVALID_ARGUMENT", "Video bytes cannot be null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val savedPath = saveVideoToMediaStore(videoBytes, fileNamePrefix)
                        result.success(savedPath)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.localizedMessage, null)
                    }
                }
                "generateAndSaveVideo" -> {
                    val slidePaths = call.argument<List<String>>("slidePaths")
                    val fileNamePrefix = call.argument<String>("fileNamePrefix") ?: "Aura_Gebelik_Yolculugu"
                    val secondsPerSlide = call.argument<Double>("secondsPerSlide") ?: 2.0

                    if (slidePaths.isNullOrEmpty()) {
                        result.error("INVALID_ARGUMENT", "Slide paths cannot be empty", null)
                        return@setMethodCallHandler
                    }

                    Thread {
                        try {
                            val savedPath = encodeAndSaveVideoFromPaths(slidePaths, fileNamePrefix, secondsPerSlide)
                            runOnUiThread {
                                result.success(savedPath)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("ENCODE_FAILED", e.localizedMessage, null)
                            }
                        }
                    }.start()
                }
                "shareLastVideo" -> {
                    try {
                        val shared = shareVideo()
                        result.success(shared)
                    } catch (e: Exception) {
                        result.error("SHARE_FAILED", e.localizedMessage, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Görseli hem Galeriye (Pictures/Aura Pregnancy) hem de İndirilenler klasörüne (Download/Aura Pregnancy) kaydeder.
     * MediaScannerConnection ile anında sistem galerisine tanıtır.
     */
    private fun saveImageToMediaStore(imageBytes: ByteArray, prefix: String): Boolean {
        val fileName = "${prefix}_${System.currentTimeMillis()}.png"
        var savedAny = false

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // 1. Galeri / Pictures / Aura Pregnancy
            try {
                val picturesValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_PICTURES}/Aura Pregnancy")
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }

                val picturesUri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, picturesValues)
                if (picturesUri != null) {
                    contentResolver.openOutputStream(picturesUri)?.use { out ->
                        out.write(imageBytes)
                        out.flush()
                    }
                    picturesValues.clear()
                    picturesValues.put(MediaStore.Images.Media.IS_PENDING, 0)
                    contentResolver.update(picturesUri, picturesValues, null, null)
                    savedAny = true
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            // 2. İndirilenler / Download / Aura Pregnancy
            try {
                val downloadValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/Aura Pregnancy")
                }
                val downloadUri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, downloadValues)
                if (downloadUri != null) {
                    contentResolver.openOutputStream(downloadUri)?.use { out ->
                        out.write(imageBytes)
                        out.flush()
                    }
                    savedAny = true
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        } else {
            // Android 9 ve altı
            try {
                val picturesDir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "Aura Pregnancy")
                if (!picturesDir.exists()) picturesDir.mkdirs()
                val imageFile = File(picturesDir, fileName)
                FileOutputStream(imageFile).use { out ->
                    out.write(imageBytes)
                    out.flush()
                }
                val values = ContentValues().apply {
                    put(MediaStore.Images.Media.DATA, imageFile.absolutePath)
                    put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                }
                contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                MediaScannerConnection.scanFile(this, arrayOf(imageFile.absolutePath), arrayOf("image/png"), null)
                savedAny = true
            } catch (e: Exception) {
                e.printStackTrace()
            }

            try {
                val downloadDir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "Aura Pregnancy")
                if (!downloadDir.exists()) downloadDir.mkdirs()
                val downloadFile = File(downloadDir, fileName)
                FileOutputStream(downloadFile).use { out ->
                    out.write(imageBytes)
                    out.flush()
                }
                MediaScannerConnection.scanFile(this, arrayOf(downloadFile.absolutePath), arrayOf("image/png"), null)
                savedAny = true
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        return savedAny
    }

    /**
     * Videoyu hem Galeri (Movies/Aura Pregnancy) hem de İndirilenler (Download/Aura Pregnancy) klasörüne kaydeder.
     */
    private fun saveVideoToMediaStore(videoBytes: ByteArray, prefix: String): String {
        val fileName = "${prefix}_${System.currentTimeMillis()}.mp4"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            var primaryUri: Uri? = null

            // 1. Galeri (Movies / Aura Pregnancy)
            try {
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_MOVIES}/Aura Pregnancy")
                    put(MediaStore.Video.Media.IS_PENDING, 1)
                }

                val uri = contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues)
                if (uri != null) {
                    contentResolver.openOutputStream(uri)?.use { outputStream ->
                        outputStream.write(videoBytes)
                        outputStream.flush()
                    }

                    contentValues.clear()
                    contentValues.put(MediaStore.Video.Media.IS_PENDING, 0)
                    contentResolver.update(uri, contentValues, null, null)

                    primaryUri = uri
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            // 2. İndirilenler (Download / Aura Pregnancy)
            try {
                val downloadValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/Aura Pregnancy")
                }
                val downloadUri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, downloadValues)
                if (downloadUri != null) {
                    contentResolver.openOutputStream(downloadUri)?.use { outputStream ->
                        outputStream.write(videoBytes)
                        outputStream.flush()
                    }
                    if (primaryUri == null) primaryUri = downloadUri
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            lastSavedVideoUri = primaryUri
            return "Galeri & İndirilenler / Aura Pregnancy / $fileName"
        } else {
            // Android 9 ve altı
            val moviesDir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES), "Aura Pregnancy")
            if (!moviesDir.exists()) moviesDir.mkdirs()
            val videoFile = File(moviesDir, fileName)
            FileOutputStream(videoFile).use { outputStream ->
                outputStream.write(videoBytes)
                outputStream.flush()
            }

            val downloadDir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "Aura Pregnancy")
            if (!downloadDir.exists()) downloadDir.mkdirs()
            val downloadFile = File(downloadDir, fileName)
            FileOutputStream(downloadFile).use { outputStream ->
                outputStream.write(videoBytes)
                outputStream.flush()
            }

            val contentValues = ContentValues().apply {
                put(MediaStore.Video.Media.DATA, videoFile.absolutePath)
                put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
            }
            val uri = contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues)
            lastSavedVideoUri = uri ?: Uri.fromFile(videoFile)

            MediaScannerConnection.scanFile(this, arrayOf(videoFile.absolutePath, downloadFile.absolutePath), arrayOf("video/mp4"), null)

            return "Galeri & İndirilenler / Aura Pregnancy / $fileName"
        }
    }

    /**
     * Geçici diskteki PNG slayt dosyalarından donanım H.264 AVC ile yüksek performanslı, düşük MB video üretir.
     */
    private fun encodeAndSaveVideoFromPaths(slidePaths: List<String>, prefix: String, secondsPerSlide: Double): String {
        val width = 720
        val height = 1280
        val fps = 25
        val framesPerSlide = (fps * secondsPerSlide).toInt().coerceAtLeast(fps)
        val bitRate = 1_200_000 // 1.2 Mbps (Hafif dosya boyutu, yüksek netlik)

        val tempFile = File(cacheDir, "${prefix}_${System.currentTimeMillis()}.mp4")
        val mimeType = "video/avc"

        val format = MediaFormat.createVideoFormat(mimeType, width, height).apply {
            setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar)
            setInteger(MediaFormat.KEY_BIT_RATE, bitRate)
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        }

        val encoder = MediaCodec.createEncoderByType(mimeType)
        encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        encoder.start()

        val muxer = MediaMuxer(tempFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        var trackIndex = -1
        var muxerStarted = false
        val bufferInfo = MediaCodec.BufferInfo()

        val yuvBuffer = ByteArray(width * height * 3 / 2)
        val argbBuffer = IntArray(width * height)
        var frameIndex = 0

        try {
            for (path in slidePaths) {
                val file = File(path)
                if (!file.exists() || file.length() == 0L) continue

                val originalBmp = BitmapFactory.decodeFile(file.absolutePath) ?: continue
                val scaledBmp = Bitmap.createScaledBitmap(originalBmp, width, height, true)
                scaledBmp.getPixels(argbBuffer, 0, width, 0, 0, width, height)
                rgbToYuv420SemiPlanar(argbBuffer, width, height, yuvBuffer)
                if (scaledBmp != originalBmp) {
                    scaledBmp.recycle()
                }
                originalBmp.recycle()

                for (f in 0 until framesPerSlide) {
                    val inputBufferIndex = encoder.dequeueInputBuffer(10000)
                    if (inputBufferIndex >= 0) {
                        val inputBuffer = encoder.getInputBuffer(inputBufferIndex)
                        inputBuffer?.clear()
                        inputBuffer?.put(yuvBuffer)
                        val pts = (frameIndex.toLong() * 1_000_000L) / fps
                        encoder.queueInputBuffer(inputBufferIndex, 0, yuvBuffer.size, pts, 0)
                        frameIndex++
                    }

                    // Drain encoder
                    while (true) {
                        val outputBufferIndex = encoder.dequeueOutputBuffer(bufferInfo, 0)
                        if (outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                            if (!muxerStarted) {
                                trackIndex = muxer.addTrack(encoder.outputFormat)
                                muxer.start()
                                muxerStarted = true
                            }
                        } else if (outputBufferIndex >= 0) {
                            val outputBuffer = encoder.getOutputBuffer(outputBufferIndex)
                            if (outputBuffer != null && bufferInfo.size > 0 && muxerStarted) {
                                muxer.writeSampleData(trackIndex, outputBuffer, bufferInfo)
                            }
                            encoder.releaseOutputBuffer(outputBufferIndex, false)
                        } else {
                            break
                        }
                    }
                }
            }

            // End of stream
            val eosIndex = encoder.dequeueInputBuffer(10000)
            if (eosIndex >= 0) {
                val pts = (frameIndex.toLong() * 1_000_000L) / fps
                encoder.queueInputBuffer(eosIndex, 0, 0, pts, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
            }

            while (true) {
                val outputBufferIndex = encoder.dequeueOutputBuffer(bufferInfo, 10000)
                if (outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    if (!muxerStarted) {
                        trackIndex = muxer.addTrack(encoder.outputFormat)
                        muxer.start()
                        muxerStarted = true
                    }
                } else if (outputBufferIndex >= 0) {
                    val outputBuffer = encoder.getOutputBuffer(outputBufferIndex)
                    if (outputBuffer != null && bufferInfo.size > 0 && muxerStarted) {
                        muxer.writeSampleData(trackIndex, outputBuffer, bufferInfo)
                    }
                    encoder.releaseOutputBuffer(outputBufferIndex, false)
                    if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                        break
                    }
                } else if (outputBufferIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
                    break
                }
            }
        } finally {
            try {
                encoder.stop()
                encoder.release()
            } catch (_: Exception) {}

            try {
                if (muxerStarted) {
                    muxer.stop()
                }
                muxer.release()
            } catch (_: Exception) {}
        }

        if (!tempFile.exists() || tempFile.length() == 0L) {
            throw IllegalStateException("Video dosyası üretilemedi.")
        }

        val videoBytes = tempFile.readBytes()
        val savedPath = saveVideoToMediaStore(videoBytes, prefix)
        tempFile.delete()

        return savedPath
    }

    private fun rgbToYuv420SemiPlanar(argb: IntArray, width: Int, height: Int, yuv: ByteArray) {
        val frameSize = width * height
        var yIndex = 0
        var uvIndex = frameSize

        for (j in 0 until height) {
            for (i in 0 until width) {
                val pixel = argb[j * width + i]
                val r = (pixel shr 16) and 0xff
                val g = (pixel shr 8) and 0xff
                val b = pixel and 0xff

                val y = ((66 * r + 129 * g + 25 * b + 128) shr 8) + 16
                val u = ((-38 * r - 74 * g + 112 * b + 128) shr 8) + 128
                val v = ((112 * r - 94 * g - 18 * b + 128) shr 8) + 128

                yuv[yIndex++] = y.coerceIn(0, 255).toByte()

                if (j % 2 == 0 && i % 2 == 0) {
                    yuv[uvIndex++] = u.coerceIn(0, 255).toByte()
                    yuv[uvIndex++] = v.coerceIn(0, 255).toByte()
                }
            }
        }
    }

    private fun shareVideo(): Boolean {
        val uri = lastSavedVideoUri ?: return false
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "video/mp4"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(shareIntent, "Time-Lapse Videonu Paylaş"))
        return true
    }
}
