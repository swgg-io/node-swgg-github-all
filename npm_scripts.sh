#!/bin/sh
# jslint-utility2

shNpmScriptApidocRawCreate() {(set -e
# this function will create the raw apidoc
    cd tmp/apidoc.raw
    find developer.github.com/v3 -name index.html | \
        sed -e "s/\/index.html//" | \
        sort | \
        sed -e "s/\(developer.github.com\/.*\)/\1\/index.html/" | \
        xargs -I @ -n 1 sh -c "printf '\\n@\\n' && cat @" | \
        sed -e "s| *\$||" > .apidoc.raw.html
    cp .apidoc.raw.html ../..
)}

shNpmScriptApidocRawFetch() {(set -e
# this function will fetch the raw apidoc
    mkdir -p tmp/apidoc.raw && cd tmp/apidoc.raw
    rm -fr developer.github.com && mkdir -p developer.github.com/v3
    curl -Lfs -o developer.github.com/v3/index.html https://developer.github.com/v3/index.html
    node -e '
// <script>
/*jslint
    bitwise: true,
    browser: true,
    maxerr: 8,
    maxlen: 100,
    node: true,
    nomen: true,
    regexp: true,
    stupid: true
*/
"use strict";
var local;
local = require("../../assets.utility2.rollup.js");
local.dict = {};
local.fs.readFileSync("developer.github.com/v3/index.html", "utf8").replace((
    /href="(\/v3\/.*?)["#]/g
), function (match0, match1) {
    match0 = match1;
    match0 = (match0 + "/").replace("//", "/");
    local.dict[match0] = true;
});
local.onParallelList({ list: Object.keys(local.dict).sort() }, function (options, onParallel) {
    onParallel.counter += 1;
    options.file = "developer.github.com" + options.element + "index.html";
    local.ajax({ url: "https://" + options.file }, function (error, xhr) {
        local.fsWriteFileWithMkdirpSync(options.file, xhr.responseText);
        console.error((options.ii + 1) + ". fetched " + options.file);
        onParallel(error);
    });
}, local.onErrorDefault);
// </script>
' 2>&1 | tee apidocRawFetch.log
)}

shNpmScriptPostinstall() {
# this function will do nothing
    return
}

# run command
"$@"
