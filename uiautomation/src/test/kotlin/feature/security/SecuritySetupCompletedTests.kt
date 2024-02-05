package feature.security

import helper.TestBase
import navigator.OnboardingNavigator
import navigator.screen.OnboardingScreen
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junitpioneer.jupiter.RetryingTest
import screen.personalize.PersonalizeInformScreen
import screen.security.SecuritySetupCompletedScreen

@DisplayName("UC 2.1 - Wallet creates account, initializes and confirms to user [PVW-1217]")
class SecuritySetupCompletedTests : TestBase() {

    private lateinit var securitySetupCompletedScreen: SecuritySetupCompletedScreen

    @BeforeEach
    fun setUp() {
        OnboardingNavigator().toScreen(OnboardingScreen.SecuritySetupCompleted)

        securitySetupCompletedScreen = SecuritySetupCompletedScreen()
    }

    /**
     * 1. Wallet registers device secrets to ensure wallet cannot be cloned or moved to another device.
     * >> This requirement hard, if not impossible to be tested in an e2e setup and should be validated during an audit of the app.
     */

    /**
     * 2. Wallet registers the new device and user with the wallet provider.
     * >> This requirement hard, if not impossible to be tested in an e2e setup and should be validated during an audit of the app.
     */

    /**
     * 3. Wallet registers such that possession of device and knowledge of PIN are both required to authenticate in future (UCs 2.3 and 2.4).
     * >> This requirement hard, if not impossible to be tested in an e2e setup and should be validated during an audit of the app.
     */

    @RetryingTest(value = MAX_RETRY_COUNT, name = "{displayName} - {index}")
    @DisplayName("4. Wallet confirms setup to user and offers button to start personalization flow.")
    fun verifyStartPersonalization() {
        securitySetupCompletedScreen.clickNextButton()

        val personalizeInformScreen = PersonalizeInformScreen()
        assertTrue(personalizeInformScreen.visible(), "personalize inform screen is not absent")
    }
}
