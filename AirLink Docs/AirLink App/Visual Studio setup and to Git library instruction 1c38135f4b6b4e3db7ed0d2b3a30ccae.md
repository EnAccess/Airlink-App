# Visual Studio setup and to Git library instructions (Mac)

Download [Xamarin - Visual Studio for Mac (~2+GB)](https://visualstudio.microsoft.com/vs/mac/xamarin/). If you want to build your application for iOS, you will also need Xcode (12+GB), which Visual studio will prompt you to install once it is done installing itself.

 

### Setting up the GitHub repository:

In Github Airlink repository: Copy the HTTPS clone link:

![Screen Shot 2021-10-04 at 10.53.38 AM.png](Visual%20Studio%20setup%20and%20to%20Git%20library%20instruction%201c38135f4b6b4e3db7ed0d2b3a30ccae/Screen_Shot_2021-10-04_at_10.53.38_AM.png)

In the visual studio menu, instead of creating a new project from the startup popup screen, go to Menu and select Clone Repository...

![Screen Shot 2021-10-04 at 10.52.50 AM.png](Visual%20Studio%20setup%20and%20to%20Git%20library%20instruction%201c38135f4b6b4e3db7ed0d2b3a30ccae/Screen_Shot_2021-10-04_at_10.52.50_AM.png)

Paste the link copied from Github

![Screen Shot 2021-10-04 at 10.53.55 AM.png](Visual%20Studio%20setup%20and%20to%20Git%20library%20instruction%201c38135f4b6b4e3db7ed0d2b3a30ccae/Screen_Shot_2021-10-04_at_10.53.55_AM.png)

That's it! Visual studio will create the project. You might need to allow it to download additional components as required.

![Screen Shot 2021-10-04 at 10.52.11 AM.png](Visual%20Studio%20setup%20and%20to%20Git%20library%20instruction%201c38135f4b6b4e3db7ed0d2b3a30ccae/Screen_Shot_2021-10-04_at_10.52.11_AM.png)

To post updates to the project, you will need to request developer access from EnAccess as well as setup a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

[A more secure GitHub Experience](https://devblogs.microsoft.com/visualstudio/a-more-secure-github-experience/?WT.mc_id=modinfra-0000-abartolo)

We recommend that you use GitHub Desktop to push changes rather than VisualStudio for Mac due to ease of use:

[GitHub Desktop](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwjPipmGwbbzAhVIUxoKHRIfAcUQFnoECBgQAQ&url=https%3A%2F%2Fdesktop.github.com%2F&usg=AOvVaw3Q4aArCExy0qKbKQYeMfD4)

### For Apple chip (M1 and above) users, setting up the debugger:

Note: to access Bluetooth and run the AirLink App, you will still need an actual phone to debug

[Setting Up an M1 Mac for Xamarin Development](https://montemagno.com/setting-up-an-m1-mac-for-xamarin-development/)