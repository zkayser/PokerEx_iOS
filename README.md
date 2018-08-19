# PokerEx_iOS

This is an iOS client application for the PokerEx API server [here](https://github.com/zkayser/poker_ex). 
The server is written in Phoenix and Elixir. To run this application with the server, you will have to clone the server
project and have Elixir, Phoenix, and Erlang installed on your machine. There are directions for running the server
in the README for that repo. 

PokerEx_iOS pulls in its dependencies through Cocoapods. If you are new to Cocoapods, check out their Getting Started Guide [here](https://guides.cocoapods.org/using/getting-started.html).
Once you are setup with Cocoapods, you can navigate to the root directory of PokerEx_iOS and run `pod install` to bring in the required third party dependencies used in the app.

To build environment-specific variables into the app, we are currently defining variables in `Dev.xcconfig` and `Release.xcconfig` files.
If you look at the app's `info.plist` file, you will see that some sensitive environment variables are necessary and are defined like this: 

```
FacebookAppId          $(FACEBOOK_APP_ID)
```

The $(FACEBOOK_APP_ID) is stored in the .xcconfig files and defined like this:

```
FACEBOOK_APP_ID = SOME_APP_ID_0000000
```

You will need several of these environment variables defined to run the app. If you do not have a Facebook Developer account, you can either remove the dependency on Facebook all together or you can register at [developers.facebook.com](https://developers.facebook.com/)

The environment variables being defined right now are: 
FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, FACEBOOK_URL_SCHEME, FACEBOOK_DISPLAY_NAME, and SERVER_URL.

To communicate with the Elixir/Phoenix backend, `SERVER_URL` is being defined as `localhost:8080/` for development builds.
