package nl.rijksoverheid.edi.wallet.platform_support.keystore

import android.security.keystore.KeyProperties
import androidx.test.ext.junit.runners.AndroidJUnit4
import nl.rijksoverheid.edi.wallet.platform_support.util.toByteArray
import nl.rijksoverheid.edi.wallet.platform_support.util.toUByteList
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.security.KeyFactory
import java.security.Signature
import java.security.spec.X509EncodedKeySpec
import kotlin.text.Charsets.US_ASCII

@RunWith(AndroidJUnit4::class)
class ECDSAKeyInstrumentedTest {

    companion object {
        private const val KEY_1_IDENTIFIER = "key1"
        private const val KEY_2_IDENTIFIER = "key2"
    }


    private lateinit var hwKeyStoreBridge: HwKeyStoreBridge

    @Before
    fun setup() {
        hwKeyStoreBridge = HwKeyStoreBridge.bridge as HwKeyStoreBridge
    }

    @After
    fun cleanup() {
        hwKeyStoreBridge.clean()
    }

    @Test
    fun test_init() {
        val key1 = hwKeyStoreBridge.getOrCreateSigningKey(KEY_1_IDENTIFIER)
        val key1again = hwKeyStoreBridge.getOrCreateSigningKey(KEY_1_IDENTIFIER)
        assertNotEquals(
            "Keys with same identifier are wrapped in different objects",
            key1,
            key1again
        )
    }

    @Test
    fun test_pub_key() {
        val key1 = hwKeyStoreBridge.getOrCreateSigningKey(KEY_1_IDENTIFIER) as ECDSAKey
        val key1again = hwKeyStoreBridge.getOrCreateSigningKey(KEY_1_IDENTIFIER) as ECDSAKey
        val key2 = hwKeyStoreBridge.getOrCreateSigningKey(KEY_2_IDENTIFIER) as ECDSAKey
        assertEquals(
            "Keys with the same identifier should be equal",
            key1.publicKey(),
            key1again.publicKey()
        )
        assertNotEquals(
            "Keys with a different identifier should not be equal",
            key1.publicKey(),
            key2.publicKey()
        )
    }

    @Test
    fun test_sign() {
        val key1 = hwKeyStoreBridge.getOrCreateSigningKey(KEY_1_IDENTIFIER) as ECDSAKey
        val key1again = hwKeyStoreBridge.getOrCreateSigningKey(KEY_1_IDENTIFIER) as ECDSAKey
        val key2 = hwKeyStoreBridge.getOrCreateSigningKey(KEY_2_IDENTIFIER) as ECDSAKey


        val message = "This is a message that will be signed."

        val emptySignature = key1.sign(emptyList())
        val signature1 = key1.sign(message.toByteArray(charset = US_ASCII).toUByteList())
        val signature1Repeat =
            key1.sign(message.toByteArray(charset = US_ASCII).toUByteList())
        val signature1Again =
            key1again.sign(message.toByteArray(charset = US_ASCII).toUByteList())
        val signature2 = key2.sign(message.toByteArray(charset = US_ASCII).toUByteList())

        assertTrue("An empty payload should produce a signature", emptySignature.size > 0)
        assertNotEquals(
            "Signatures signed with the same key instance should differ",
            signature1,
            signature1Repeat
        )
        assertNotEquals(
            "Signatures signed with the same key should differ",
            signature1,
            signature1Again
        )
        assertNotEquals(
            "Signatures signed with a different key should differ",
            signature1,
            signature2
        )
    }

    @Test
    fun test_verify_signature() {
        val key1 = hwKeyStoreBridge.getOrCreateSigningKey(KEY_1_IDENTIFIER) as ECDSAKey
        val message = "This is a message that will be signed."

        val signature1 = key1.sign(message.toByteArray(charset = US_ASCII).toUByteList())
        val signature1Repeat =
            key1.sign(message.toByteArray(charset = US_ASCII).toUByteList())

        assertTrue(
            "Signature should be valid",
            isValidSignature(
                signature1.toByteArray(),
                message.toByteArray(),
                key1.publicKey().toByteArray()
            )
        )
        assertTrue(
            "Signature should be valid",
            isValidSignature(
                signature1Repeat.toByteArray(),
                message.toByteArray(),
                key1.publicKey().toByteArray()
            )
        )
    }

    @Test
    fun test_signature_mismatch() {
        val key1 = hwKeyStoreBridge.getOrCreateSigningKey(KEY_1_IDENTIFIER) as ECDSAKey
        val key2 = hwKeyStoreBridge.getOrCreateSigningKey(KEY_2_IDENTIFIER) as ECDSAKey
        val message = "This is a message that will be signed."
        val otherMessage = "Some other message"
        assertNotEquals(
            "Messages used to verify signature mismatch should not be equal",
            message,
            otherMessage
        )

        val signature1 = key1.sign(message.toByteArray(charset = US_ASCII).toUByteList())

        assertFalse(
            "Signature from different key should not be valid",
            isValidSignature(
                signature1.toByteArray(),
                message.toByteArray(),
                key2.publicKey().toByteArray()
            )
        )
        assertFalse(
            "Signature with different payload should not be valid",
            isValidSignature(
                signature1.toByteArray(),
                otherMessage.toByteArray(),
                key1.publicKey().toByteArray()
            )
        )
    }

    private fun isValidSignature(
        signatureBytes: ByteArray,
        payload: ByteArray,
        publicKeyBytes: ByteArray
    ): Boolean {
        val x509EncodedKeySpec = X509EncodedKeySpec(publicKeyBytes)
        val keyFactory: KeyFactory = KeyFactory.getInstance(KeyProperties.KEY_ALGORITHM_EC)
        val publicKey = keyFactory.generatePublic(x509EncodedKeySpec)
        val signature = Signature.getInstance(SIGNATURE_ALGORITHM)
        signature.initVerify(publicKey)
        signature.update(payload)
        return signature.verify(signatureBytes)
    }
}