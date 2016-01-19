#Unofficial Grindr API documentation

##Authentication

- Web login or sign-up (once per device): POST `https://neo-account.grindr.com/sessions` or `/https://neo-account.grindr.com/users` with `email`, `password` and `recaptcha_response_field` as URL-encoded parameters. Redirects you to `grindr-account://*?authenticationToken=#{AUTHENTICATION_TOKEN}&email=*&profileId=#{PROFILE_ID}`. The authentication token is reusable.
- HTTP Authentication (once per session): POST `https://primus.grindr.com/2.0/session` with `appName`, `appVersion`, `authenticationToken`, `deviceIdentifier` (random UUID), `platformName`, `platformVersion` and `profileId` as URL-encoded parameters. Returns Session-Id HTTP header and `xmppToken` in JSON-encoded body.

##Chat
XMPP connection: `#{PROFILE_ID}@chat.grindr.com` with `xmppToken` as the password.

Message format:

    {
        "targetProfileId": ''
        "type": "text, image, map or block"
        "messageId": "Random UUID"
        "timestamp": ...
        "sourceDisplayName": ''
        "sourceProfileId": '(spoofing this may still be possible)'
        "body": "{text}, {imageHash} or {lat, lon}"
    }

While connected, XMPP messages are sent from `#{SOURCE_PROFILE_ID}@chat.grindr.com` to `#{TARGET_PROFILE_ID}@chat.grindr.com` and their body is a JSON-encoded message object.

To retrieve missed messages after re-connecting, POST `https://primus.grindr.com/2.0/undeliveredChatMessages` and read the JSON-encoded array of message objects.

To acknowledge messages, POST `https://primus.grindr.com/2.0/confirmChatMessagesDelivered` with `{"messageIds": ['...']}` as body

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
                "distance": distance in km, 
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
