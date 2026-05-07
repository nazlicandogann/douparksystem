package com.doupark.backend.service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.UUID;

/**
 * QR Kodu üretim servisi.
 * - generateQrToken(): Tek kullanımlık benzersiz UUID üretir.
 * - generateQrImage(): Token'ı QR PNG görseline çevirir (Base64 veya byte[]).
 */
@Service
public class QrService {

    private static final int QR_SIZE = 300; // piksel

    /**
     * Tek kullanımlık benzersiz QR token üretir.
     */
    public String generateQrToken() {
        return UUID.randomUUID().toString();
    }

    /**
     * Verilen metni QR koduna çevirip PNG byte dizisi döner.
     * Flutter tarafında Image.memory() ile doğrudan gösterilebilir.
     */
    public byte[] generateQrImageBytes(String content) {
        QRCodeWriter writer = new QRCodeWriter();
        try {
            BitMatrix bitMatrix = writer.encode(content, BarcodeFormat.QR_CODE, QR_SIZE, QR_SIZE);
            ByteArrayOutputStream pngOutputStream = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", pngOutputStream);
            return pngOutputStream.toByteArray();
        } catch (WriterException | IOException e) {
            throw new RuntimeException("QR kodu üretilemedi: " + e.getMessage(), e);
        }
    }
}
