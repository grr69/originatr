#[fuckr](http://fuckr.me/): Grindr™ for [Mac](http://fuckr.me/downloads/Fuckr.dmg) and [Windows](http://fuckr.me/downloads/Fuckr.zip)

fuckr is a Grindr™ client for desktop built with Node-Webkit, AngularJS and a modified version of [jacasr](https://github.com/tdebarochez/jacasr) (bundled in `fuckr/node_modules`).

##Run
First, install node-webkit (eg. `npm install -g nodewebkit`). Then

    cd fuckr/
    nw .

##Package

    npm install
    node package.js

##Grindr API
All interactions with Grindr's API are in [fuckr/services](fuckr/services) and summarized in this [unofficial Grindr API documentation](unofficial-grindr-api-documentation.md).
If there's anything else you want to know, you can easily analyse the HTTPS part with [mitmproxy](http://mitmproxy.org/)'s [regular proxy](https://mitmproxy.org/doc/modes.html) mode and the XMPP part with just Wireshark (+ Ettercap) since the official grindr client doesn't bother encrypting that part!

##Credits
- Logo: [Reyson Morales](http://reyson-morales.deviantart.com/)
- Contributions: [Victor Grego](https://github.com/victorgrego)
- Download Page: copied from [Tinder++](https://github.com/mfkp/tinderplusplus)
