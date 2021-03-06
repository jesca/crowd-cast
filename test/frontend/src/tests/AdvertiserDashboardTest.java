package tests;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.Test;

import pages.DashboardPage;
import pages.FrontPage;
import strings.LocatorStrings;

/* Tests that after logging in as owner and clicking on the logo, we are taken to the owner dashboard */
public class AdvertiserDashboardTest {
	  @Test 
	  public void advertiserDashboardTest() {
			  
	    WebDriver driver = new FirefoxDriver();
	      
	    try {
	        FrontPage f = new FrontPage(driver).open().clickLogin();
	        WebDriverWait wait = new WebDriverWait(driver, 10);
	        WebElement element = wait.until(ExpectedConditions.elementToBeClickable(By.id("login")));
	        String credentials = LocatorStrings.UsernameAdvertiser;
	        f.loginSuccess(credentials,credentials);
	        
	        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("add-ad-button")));
	        DashboardPage d = f.clickOnLogoLoggedIn();
	        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("sidebar")));
	        assert d.getUrl().contains("advertiser_dashboard"): "Expected dasbhoard url to contain 'advertiser_dashboard' but got: " + d.getUrl();
	        
	    }
	    finally {
	    	driver.quit();
	    }
	  }
	

}
