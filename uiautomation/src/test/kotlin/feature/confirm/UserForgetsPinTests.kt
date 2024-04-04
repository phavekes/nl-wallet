package feature.confirm

import helper.TestBase
import navigator.OnboardingNavigator
import navigator.screen.OnboardingScreen
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junitpioneer.jupiter.RetryingTest
import screen.security.ForgotPinScreen
import screen.security.PinScreen

@DisplayName("${UserForgetsPinTests.USE_CASE} User forgets pin [${UserForgetsPinTests.JIRA_ID}]")
class UserForgetsPinTests : TestBase() {

    companion object {
        const val USE_CASE = "UC 2.4"
        const val JIRA_ID = "PVW-1120"
    }

    private lateinit var forgotPinScreen: ForgotPinScreen

    @BeforeEach
    fun setUp() {
        OnboardingNavigator().toScreen(OnboardingScreen.PersonalizeConfirmIssuance)

        PinScreen().clickForgotPinButton()

        forgotPinScreen = ForgotPinScreen()
    }

    @RetryingTest(value = MAX_RETRY_COUNT, name = "{displayName} - {index}")
    @DisplayName("$USE_CASE.1 The app explains that the user has to reset the wallet in order to regain access.")
    fun verifyForgotPin() {
        assertTrue(forgotPinScreen.visible(), "forgot pin screen is not visible")
    }

    @RetryingTest(value = MAX_RETRY_COUNT, name = "{displayName} - {index}")
    @DisplayName("$USE_CASE.2 The app explains that upon resetting the wallet, data CANNOT be recovered.")
    fun verifyDataLoss() {
        assertTrue(forgotPinScreen.dataLossTextVisible(), "data loss description text is not visible")
    }

    @RetryingTest(value = MAX_RETRY_COUNT, name = "{displayName} - {index}")
    @DisplayName("$USE_CASE.3 The app offers an entrance to resetting the app.")
    fun verifyResetButton() {
        assertTrue(forgotPinScreen.resetButtonVisible(), "reset wallet button is not visible")
    }

    @RetryingTest(value = MAX_RETRY_COUNT, name = "{displayName} - {index}")
    @DisplayName("$USE_CASE.4 The user can go back to the PIN entry screen.")
    fun verifyBackButton() {
        forgotPinScreen.clickBottomBackButton()

        val pinScreen = PinScreen()
        assertTrue(pinScreen.personalizeConfirmPinScreenVisible(), "personalize confirm pin screen is not visible")
    }
}
