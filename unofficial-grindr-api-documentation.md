#Unofficial Grindr API documentation

##Services List
Issue an unauthenticated GET request to `https://primus.grindr.com/2.0/services` to get a list of server names you'll use.  Example response:

	{
	  "chat" : [ {
	    "host" : "chat.grindr.com",
	    "port" : 5222,
	    "protocol" : "xmpp",
	    "domain" : "chat.grindr.com"
	  }, ... ],
	  "media" : [ {
	    "host" : "cdns.grindr.com",
	    "port" : 80,
	    "protocol" : "http",
	    "path" : ""
	  } ],
	  "authenticationWeb" : [ {
	    "host" : "neo-account.grindr.com",
	    "port" : 443,
	    "protocol" : "https",
	    "path" : ""
	  } ],
	  "web" : [ {
	    "host" : "neo-store.grindr.com",
	    "port" : 443,
	    "protocol" : "https",
	    "path" : "/"
	  } ],
	  "upload" : [ {
	    "host" : "neo-upload.grindr.com",
	    "port" : 443,
	    "protocol" : "https",
	    "path" : ""
	  } ]
	}

##Managed fields

Grindr has several named lists that they can update on the server.  For example, the "ethnicity" value of 3 might map to the string "Latino".  You can download the current definition by issuing an unauthenticated GET to `https://primus.grindr.com/2.0/managedFields`.  Example server response:

    {"fields":{
        "relationshipStatus":[{"fieldId":4,"name":"Committed"},{"fieldId":2,"name":"Dating"},{"fieldId":6,"name":"Engaged"},{"fieldId":3,"name":"Exclusive"},{"fieldId":7,"name":"Married"},{"fieldId":8,"name":"Open Relationship"},{"fieldId":5,"name":"Partnered"},{"fieldId":1,"name":"Single"}],
        "bodyType":[{"fieldId":1,"name":"Toned"},{"fieldId":2,"name":"Average"},{"fieldId":3,"name":"Large"},{"fieldId":4,"name":"Muscular"},{"fieldId":5,"name":"Slim"},{"fieldId":6,"name":"Stocky"}],
        "lookingFor":[{"fieldId":2,"name":"Chat"},{"fieldId":3,"name":"Dates"},{"fieldId":4,"name":"Friends"},{"fieldId":5,"name":"Networking"},{"fieldId":6,"name":"Relationship"},{"fieldId":7,"name":"Right Now"}],
        "ethnicity":[{"fieldId":1,"name":"Asian"},{"fieldId":2,"name":"Black"},{"fieldId":3,"name":"Latino"},{"fieldId":4,"name":"Middle Eastern"},{"fieldId":5,"name":"Mixed"},{"fieldId":6,"name":"Native American"},{"fieldId":8,"name":"Other"},{"fieldId":9,"name":"South Asian"},{"fieldId":7,"name":"White"}],
        "grindrTribes":[{"fieldId":1,"name":"Bear"},{"fieldId":2,"name":"Clean-Cut"},{"fieldId":3,"name":"Daddy"},{"fieldId":4,"name":"Discreet"},{"fieldId":5,"name":"Geek"},{"fieldId":6,"name":"Jock"},{"fieldId":7,"name":"Leather"},{"fieldId":8,"name":"Otter"},{"fieldId":9,"name":"Poz"},{"fieldId":10,"name":"Rugged"},{"fieldId":11,"name":"Trans"},{"fieldId":12,"name":"Twink"}],
        "reportReasons":[{"fieldId":1,"name":"Offensive profile image"},{"fieldId":2,"name":"Offensive profile text"},{"fieldId":4,"name":"Abusive User"},{"fieldId":5,"name":"Solicitation/Spam"},{"fieldId":7,"name":"Under Age"},{"fieldId":10,"name":"Impersonation"}]
    }}

##Client configuration
Optionally issue an authenticated GET to `https://primus.grindr.com/2.0/rules` to obtain several policies.  This appears to enforce the client-side premium features.  Example response:

	{
		"serverTime": 1452362929064,
		"location.max.seconds": 90,
		"location.min.feet": 150,
		"cascade.max.seconds": 420,
		"cascade.min.seconds": 10,
		"app.bannerAds.enabled": true,
		"app.requestRetryAfterFailureDefault.seconds": 120,
		"app.interstitialAds.enabled": true,
		"app.dailyBlock.limit": 10,
		"app.dailyFav.limit": 10,
		"app.cascadeGuys.limit": 100,
		"app.advancedFilters.enabled": false,
		"app.advancedChatFeatures.enabled": false,
		"app.pushNotifications.enabled": false,
		"app.xtraSubscription.secondsRemaining": 0,
		"app.chatHistory.days": 180,
		"app.backgroundConnectionTTL.seconds": 90,
		"app.profileSwipe.enabled": false,
		"app.onlineTimeCutOff.seconds": 600
	}

##First-time setup

If this is the first time the user has logged into the device, you'll need to get an `authenticationToken`.  This token is a password-equivalent, and is meant to be saved (securely) on the device, to avoid needing to type the password each time the app is launched.  Send the user to one of these  URLs and display the HTML response in a web browser:
- To create a new account: `https://neo-account.grindr.com/signup`
- To sign into an existing account: `https://neo-account.grindr.com/login`
- To let the user pick: `https://neo-account.grindr.com/`

After the user fills out form fields `email`, `password` and `recaptcha_response_field` and clicks submit, the webpage will eventually try to redirect to a custom URI scheme `grindr-account`.  Example URI:

    grindr-account://login?authenticationToken=abcdef1234567890abcdef12342123412341234123412341234123412341234a&email=user@example.com&profileId=12345678

or

    grindr-account://accountcreate?authenticationToken=abcdef1234567890abcdef12342123412341234123412341234123412341234a&email=user@example.com&profileId=12345678

Parse the URL to extract the `authenticationToken` and save this in persistent storage.  You'll reuse the `authenticationToken` every time you want to log into this account.

##Authentication

Every time you launch the app, you need to get a new `Session-ID `(to interact with HTTP services) and a new `xmppToken` (to interact with the XMPP chat server).  Issue a POST to `https://primus.grindr.com/2.0/session`. Example request from official client:
 
    {
    	"appName": "Grindr",
    	"appVersion": "2.3.5",
    	"authenticationToken": "abcdef1234567890abcdef12342123412341234123412341234123412341234a",
    	"deviceIdentifier": "#{RANDOM_UUID}",
    	"platformName": "Android",
    	"platformVersion": "19",
    	"profileId": "12345678"
    }

The `Session-Id` must be extracted from the HTTP response headers to be reused for authenticated requests such as location update.  The `xmppToken` comes from the json-encoded response payload.  Example response:

    HTTP/1.1 200 OK
    Content-Type: application/json
    Session-Id: ABCDEF12341234123412341234012349:01234912309509123490123904102340ABCDEF123401234099124509081234ABBCDEF0129341029309530123094091230490192592309094109235909123490091092349051203940912039409102935

    {
	    "xmppToken": "987654321abcdef0987654321123412341234abcdef123412341234123412343",
    	"updateAvailable": false
    }
    
##Offline messages
The client should issue an authenticated GET to `https://primus.grindr.com/2.0/undeliveredChatMessages` to fetch any chats that were received while the client was offline.  The messages are formatted in the same way as normal online XMPP messages; see the XMPP chat section for details.  Example server response:

    {
        [
            {
                "sourceProfileId":"22222222",
                "targetProfileId":"12345678",
                "messageId":"Random UUID",
                "sourceClientId":null,
                "sourceDisplayName":null,
                "type":"text",
                "timestamp":1453912345678,
                "body":"What's up"
            },
            ...
        ]
    }

##Pushing your location
Every 90 seconds (approximately), the official client pushes its location to the server. Issue an authenticated PUT to `https://primus.grindr.com/2.0/location` with the location encoded like this:

    {
	    "profileId": "12345678",
	    "lon": -123.123456,
	    "lat": 45.678901
    }

The server appears to respond with an empty json object. It's unknown if there's any possible value returned there.

##Chat
XMPP connection: `#{PROFILE_ID}@chat.grindr.com` with `xmppToken` as the password. Use `plain` authentication.

Chat messages are delivered as XMPP `chat` tags.  The sender is `#{SOURCE_PROFILE_ID}@chat.grindr.com`. The body of a chat message is actually a json-encoded object, with the real chat message embedded inside the json. Example `chat` body:

    {
        "targetProfileId": ''
        "type": "text, image, map or block"
        "messageId": "Random UUID"
        "timestamp": ...
        "sourceDisplayName": ''
        "sourceProfileId": '(spoofing this may still be possible)'
        "body": "{text}, {imageHash} or {lat, lon}"
    }

To acknowledge messages, send an authenticated POST to `https://primus.grindr.com/2.0/confirmChatMessagesDelivered` with `{"messageIds": ['...']}` as body.

If the server is unable to deliver your outgoing chat message, the XMPP server may return an error via an XMPP `error` tag.  The body of the `error` message will again be a json-encoded string, which appears to repeat your outgoing message. You can use the `messageId` value that you put in the outbound message to correlate the error with the original message:

    {
        "messageId":"ABCDEF01-1234-1234-ABAB-ABCDEF123456",
        . . .
    }

##Profiles

For nearby profiles, POST `https://primus.grindr.com/2.0/nearbyProfiles` with body:

    {
        "filter": {
            "ageMaximum": 21, 
            "lookingForIds": [], 
            "onlineOnly": false, 
            "page": 1, 
            "photoOnly": false, 
            "quantity": 150
        }, 
        "lat": 40.8227028, 
        "lon": -73.9518517
    }

For specific profiles, POST `https://primus.grindr.com/2.0/getProfiles` with body:

    {
        "targetProfileIds": [
            "..."
        ]
    }

Response in both cases:

    {
        "profiles": [
            {
                "age": 19, 
                "displayName": "...", 
                "distance": distance in km (only if authenticated), 
                "ethnicity": 3, 
                "headlineDate": timestamp, 
                "height": height in cm, 
                "isFavorite": false, 
                "lookingFor": [], 
                "profileId": ..., 
                "profileImageMediaHash": "...",

                "seen": timestamp, 
                "showAge": true, 
                "showDistance": true, 
                "status": 1, 
                "version": 1419464730, 
                "weight": weight in grams
            }, 
            ...
        ]
    }

##Uploading images
Chat image: POST `https://neo-upload.grindr.com/2.0/chatImage/#{CropMaxY},#{CropMinX},#{CropMaxX},#{CropMinY}` with uncropped image as body
- Profile image: POST `https://neo-upload.grindr.com/2.0/profileImage/#{CropMaxY},#{CropMinX},#{CropMaxX},#{CropMinY}/#{squareMaxY},#{squareMinX},#{squareMaxX},#{squareMinY}` with uncropped image as body

Response:

    {
        "action": "'pending' if profile image, nothing if chat image"
        "mediaHash": "e774d95f17395f754a457f84e92a26d3bcf4f9a1"
    }


##Updating the user's profile

PUT `https://primus.grindr.com/2.0/profile` with body `{profileAttribute: value}`.
