# Typical dev-version to work on plugins. You can change the file "dev.lua" to integrate the plugins you are currently working on
lua wrap.lua start.lua artificiaOS_dev.json --slots core:type=core receiver:type=receiver

# This is a minimal core that allows normal flying with the construct. Without this, someone without the plugin files
# will not be able to even fly the construct this is installed on!
lua wrap.lua start.lua artificiaOS_0_38_min.json --slots core:type=core --plugins register slots basefly --minify

# Bare-bone function and interface
lua wrap.lua start.lua artificiaOS_0_38_bareBone.json --slots core:type=core --plugins register slots basefly hud artificialhorizon multiscreener config --minify

# Release including all current modules
lua wrap.lua start.lua artificiaOS_0_38_myOwnRelease.json --slots core:type=core --plugins register slots basefly hud artificialhorizon multiscreener config repairmonitor itemlist whispernet bankraid ec25519 keychain morus base64  --minify

# Autoconf DOES NOT SUPPORT some combinations of event handlers, ONLY USE FOR TESTING!
lua wrap.lua start.lua artificiaOS_0_38_min.conf --output yaml --name "ArtificiaOS 0.38 minimal core" --slots icore:type=core --plugins register slots basefly --minify
# Bare-bone function and interface
lua wrap.lua start.lua artificiaOS_0_38_bareBone.conf --output yaml --name "ArtificiaOS 0.38 BareBone" --slots core:type=core --plugins register slots basefly hud artificialhorizon multiscreener config --minify
lua wrap.lua start.lua artificiaOS_0_38_Skeletti.conf --output yaml --name "ArtificiaOS 0.38 Skeletti" --slots icore:type=core --plugins register slots basefly --minify
lua wrap.lua start.lua artificiaOS_dev.conf --output yaml --name "ArtificiaOS 0.38 Entwicklungsmodus" --slots icore:type=core ireceiver:type=receiver


lua wrap.lua start.lua artificiaOS_dev.json --slots core:type=core --plugins register slots dev