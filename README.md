# Original desktop client

Unofficial client for desktop built with Node-Webkit, AngularJS and a modified version of [jacasr](https://github.com/tdebarochez/jacasr) (bundled in `fuckr/node_modules`).

##Run
Install node-webkit >= 0.12 (eg. `npm install -g nw`) and run `nw fuckr`

##Develop
    npm install --save-dev
    npm run build
    npm run run
    npm run package

##API
All interactions with API are in ./services and summarized in ./unofficial-grindr-api-documentation.md.
If there's anything else you want to know, you can easily analyse the HTTPS part with [mitmproxy](http://mitmproxy.org/)'s [regular proxy](https://mitmproxy.org/doc/modes.html) mode and the XMPP part with just Wireshark (+ Ettercap)

##Credits
- Logo: [Reyson Morales](http://reyson-morales.deviantart.com/)
- Contributions: @victorgrego, @RobbieTechie and @shyrat
- Download Page: originally copied from [Tinder++](https://github.com/mfkp/tinderplusplus)
