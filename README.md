#[Fuckr](http://fuckr.me/): Grindr™ for Mac, Windows and Linux

Fuckr is a Grindr™ client for desktop built with Node-Webkit, AngularJS and a modified version of [jacasr](https://github.com/tdebarochez/jacasr) (bundled in `fuckr/node_modules`).

##Run
Install node-webkit >= 0.12 (eg. `npm install -g nodewebkit`) and run `nw fuckr`

##Develop

    npm install --save-dev
    npm run build
    npm run run
    npm run package

##Grindr API
All interactions with Grindr's API are in [fuckr/services](fuckr/services) and summarized in this [unofficial Grindr API documentation](unofficial-grindr-api-documentation.md).
If there's anything else you want to know, you can easily analyse the HTTPS part with [mitmproxy](http://mitmproxy.org/)'s [regular proxy](https://mitmproxy.org/doc/modes.html) mode and the XMPP part with just Wireshark (+ Ettercap) since the official grindr client doesn't bother encrypting that part!

##Credits
- Logo: [Reyson Morales](http://reyson-morales.deviantart.com/)
- Contributions: @victorgrego and @shyrat
- Download Page: copied from [Tinder++](https://github.com/mfkp/tinderplusplus)
