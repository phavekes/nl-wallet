package screen.introduction

import com.codeborne.selenide.WebDriverRunner
import io.github.ashwith.flutter.FlutterFinder

import io.qameta.allure.Step
import org.openqa.selenium.remote.RemoteWebDriver

import util.MobileActions

class IntroductionExpectationsScreen : MobileActions() {

    private val find = FlutterFinder(WebDriverRunner.getWebDriver() as RemoteWebDriver)
    private val nextButton = find.byValueKey("introductionExpectationsScreenCta")

    @Step("next button is visible")
    fun waitForButtonVisibility(): Boolean {
        return waitForVisibility(nextButton)
    }

    @Step("click next button")
    fun clickNextButton() {
        tapElement(nextButton)
    }
}