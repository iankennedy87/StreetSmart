------------------------
Welcome to Street Smart!
------------------------

The inspiration for this app was my brother's distribution business, which uses  CRM (customer relationship management) software to track his customers. I wanted to build and app to allow delivery drivers to quickly see a Google Street View of the customer that they're servicing. To do so, I found a free CRM (Insightly) and integrated it with Google Street View. The result is Street Smart.

-----
Note
-----

To save the reviewer the trouble of populating an Insightly account with customers, I've created a dummy account with a few customers, including one with a bogus address to demonstrate app behavior. The login information for this account is:

email: iankennedy87@gmail.com
password: Y3zn5QTNpaV15aR 

This account is purely for app development purposes, so feel free to manipulate the data to experiment with the app.

------------------------------
Building and Compiling the App
------------------------------
Street Smart uses Cocoa Pods to manages Google's dependencies. The dependencies are included in the GitHub file, so you should not need to reinstall the Pods. 

The project was created to run only on iOS 10.0. It will not compile on earlier versions of iOS. According to Google, there is an issue with Google Sign In with the latest iOS 10 simulators in Xcode 8. The issue does not affect real devices, but to allow Street Smart to run correctly on the simulator, I had to enable Keychain Sharing in the Capabilities section of the app on Xcode and add the project bundle identifier to Keychain Groups. 

When enabling, I was asked to enter my Apple credentials. I do not know if this will work for other users. If you encounter an issue with Google SignIn, please go through the same steps detailed above to enable Keychain Sharing with your Apple credentials. Thanks!

-------------------
1. Getting Started
-------------------
Street Smart requires Google SignIn. Click the SignIn button on the main page, and you will be directed to the Google Sign In page.

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


