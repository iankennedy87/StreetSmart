------------------------
Welcome to Street Smart!
------------------------

The inspiration for this app was my brother's distribution business, which uses CRM (customer relationship management) software to track his customers. I wanted to build and app to allow delivery drivers to quickly see a Google Street View of the customer that they're servicing. To do so, I found a free CRM (Insightly) and integrated it with Google Street View. The result is Street Smart.

-----
Note
-----

The only authentication that Insightly’s API uses is an API Key in endpoint calls. Therefore, the app includes Google SignIn to authenticate users, in addition to requiring the user to add their personal API Key to view their data. It does not include a developer API Key in the code. This design is not an oversight — it’s the only way to allow different users to access their data! The Insightly API Key is not a developer key. It’s more like a method of authentication.

To save the reviewer the trouble of populating an Insightly account with customers, I've created a dummy account with a few customers, including one with a bogus address to demonstrate app behavior. Please note that this is not a Google Account and will not work for the main page Sign In! You will need to sign in to Google with your own Google credentials. This Insightly account is only for logging into the website outside of the app to view and modify data for testing purposes. The account is purely for app development purposes, so feel free to manipulate the data to experiment with the app. The app only accesses “Organisations” from Insightly, so if you want to change something, please add an Organization or modify an existing one. 

The login information for the Insightly.com (not Google!) account is:

email: iankennedy87@gmail.com
password: Y3zn5QTNpaV15aR 

If you don’t want to modify Insightly data or visit the website, the API Key for this dummy account is: 

917b59bc-efc4-49bc-a626-dc57f65ee7d6:

You can enter this key on the “Set API Key” page of the app, and the app will run as expected.

------------------------------
Building and Compiling the App
------------------------------
Street Smart uses Cocoa Pods to manages Google's dependencies. Therefore, use the insightly.xcworkspace file to open the project. If you use the insightly.xcodeproj file, the project will not compile.  The dependencies are included in the GitHub file, so you should not need to reinstall the Pods. However, some of the Pods are very large, so it may take a few minutes to download. Finally, I deleted many of the image out of the Google dependencies to reduce the file sizes. This resulted in a few hundred warnings in XCode about missing files, but the app still compiles and runs as it should. 

The project was created to run only on iOS 10.0. It will not compile on earlier versions of iOS. According to Google, there is an issue with Google Sign In with the latest iOS 10 simulators in Xcode 8. The issue does not affect real devices, but to allow Street Smart to run correctly on the simulator, I had to enable Keychain Sharing in the Capabilities section of the app on Xcode and add the project bundle identifier to Keychain Groups. 

When enabling, I was asked to enter my Apple credentials. I do not know if this will work for other users. If you encounter an issue with Google SignIn, please go through the same steps detailed above to enable Keychain Sharing with your Apple credentials. Thanks!

-------------------
1. Getting Started
-------------------
Street Smart requires Google SignIn. Click the SignIn button on the main page, and you will be directed to the Google Sign In page. Please login with your Google credentials, not your Insightly credentials. 

(NOTE TO REVIEWER: Don’t use the dummy Insightly credentials provided above here! Use your own Google login information.)

------------------
2. Main Page
------------------
Once you successfully sign in to Google, you will be directed to Street Smart's main page. Insightly requires an API key to access your data, so if you haven't entered an API key yet, the "View Customers" button will direct you to the app's API Key entry page. You can also return to the main page and choose "Set API Key" to change the API Key at any time. Finally, "About Street Smart" takes you to a brief summary of the App.

Once you have entered an API Key, "View Customers" will begin to download your customer data from Insightly. Once the download is complete, a list of customers will display.

The "Sign Out" button on the right of the navigation bar will sign you out of Google and return you to the sign in page. 

-----------------------
3. Setting Your API Key
-----------------------
The API Key screen allows you to enter or change your Insightly API Key. There is a brief explanation of where to find the API Key on Insightly.com as well as a link to a more detailed explanation on Insightly's website. 

If you enter an API Key for the first time or change your API Key, Street Smart will download new customer data next time you select "View Customers" from the main page.

-----------------
3. View Customers
-----------------
The View Customers page displays a list of your customers saved in Insightly's database. If you change your customer data on the website, touching the Refresh icon on the right of the navigation bar will erase your old data and download the new data. 

If you do not want to see a customer in Street Smart, swipe left to delete.

Tapping a customer cell will take you to the Street View page.

---------------
4. Street View 
---------------
The Street View page displays the customer's address and a Google Street View. If Google does not have a Street View or if the address can't be converted into usable coordinates, a placeholder image will display instead. Be patient on this page. It can take a few seconds for the Google Street View to load. 

If the street view fails to load due to a bad network connection, you can press the refresh button on the right of the navigation bar to reload the street view once the network connection is reestablished.


