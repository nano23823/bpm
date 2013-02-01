default: packages build/chrome build/betterponymotes.user.js update-files build/export.json.bz2

packages: build/betterponymotes.xpi build/chrome.zip build/betterponymotes.oex

update-files: www/betterponymotes.update.rdf www/opera-updates.xml

build/export.json.bz2: build/export.json
	bzip2 -kf build/export.json

build/export.json: bpexport.py emotes/*.json data/rules.yaml
	./bpexport.py --json build/export.json

www/betterponymotes.update.rdf: build/betterponymotes.xpi

www/opera-updates.xml: build/betterponymotes.oex

www/betterponymotes.update.rdf www/opera-updates.xml:
	bin/gen_update_files.py `bin/version.py get`

build/emote-classes.css build/bpm-data.js: bpgen.py emotes/*.json data/rules.yaml
	./bpgen.py

build/betterponymotes.xpi: build/emote-classes.css build/bpm-data.js addon/firefox/data/* addon/firefox/package.json addon/firefox/lib/main.js
	rm -f build/*.xpi
	cfx xpi --update-url=http://rainbow.mlas1.us/betterponymotes.update.rdf --pkgdir=addon/firefox
	bin/inject_xpi_key.py betterponymotes.xpi build/betterponymotes.xpi
	rm betterponymotes.xpi
	cp build/betterponymotes.xpi build/betterponymotes_`bin/version.py get`.xpi

build/chrome.zip: build/emote-classes.css build/bpm-data.js addon/chrome/*
	rm -f build/chrome.zip
	cd addon/chrome && zip -r -0 -q ../../build/chrome.zip * && cd ../..

build/betterponymotes.oex: build/emote-classes.css build/bpm-data.js addon/opera/includes/* addon/opera/*
	rm -f build/*.oex
	cd addon/opera && zip -r -q ../../build/betterponymotes.oex * && cd ../..
	cp build/betterponymotes.oex build/betterponymotes_`bin/version.py get`.oex

build/chrome: build/emote-classes.css build/bpm-data.js addon/chrome/*
	cp -RL addon/chrome build
	rm -f build/chrome/key.pem

build/betterponymotes.user.js: data/betterponymotes.js bin/make_userscript.py
	bin/make_userscript.py data/betterponymotes.js build/betterponymotes.user.js http://rainbow.mlas1.us/
