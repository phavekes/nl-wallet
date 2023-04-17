package nl.rijksoverheid.edi.wallet.platform_support.keystore

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import nl.rijksoverheid.edi.wallet.platform_support.PlatformSupport
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class HWKeyStoreBridgeInstrumentedTest {

    @Before
    fun setUp() {
        System.loadLibrary("platform_support")
    }

    @Test
    fun bridge_is_initialized() {
        val context = InstrumentationRegistry.getInstrumentation().context
        val platformSupport = PlatformSupport.getInstance(context)
        assertNotNull(platformSupport.hwKeyStoreBridge)
    }

    @Test
    fun bridge_test_signature() {
        assertTrue(hw_keystore_test_hardware_signature())
    }

    @Test
    fun bridge_test_symmetric_encryption() {
        assertTrue(hw_keystore_test_hardware_encryption())
    }

    companion object {
        @JvmStatic
        external fun hw_keystore_test_hardware_signature(): Boolean

        @JvmStatic
        external fun hw_keystore_test_hardware_encryption(): Boolean
    }
}
