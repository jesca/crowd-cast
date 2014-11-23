package tests;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.testng.annotations.Test;

import pages.DashboardPage;
import pages.FrontPage;


@Test
public class LoginTest {
 
  @Test 
  public void loginLogout() {
		  
    WebDriver driver = new FirefoxDriver();
      
    try {
        FrontPage frontPage = new FrontPage(driver).open();
        //assert the page is there
        frontPage.clickLogin();
        // log in with a correct owner username
        DashboardPage ownerPage = frontPage.loginSuccess("jessica","jessicawong");
        
        // logged in. if clicked on logo, should be directed to dashboard if login passes
        String curUrl = ownerPage.getUrl();
        assert curUrl.contains("dashboard"): "expected logged in user to have the string 'dashboard' in url after clicking on the logo, but got this url instead:" + curUrl;
	 
    }
    finally {
    	driver.quit();
    }
  }
}