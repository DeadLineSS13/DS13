#!/bin/bash
set -euo pipefail

md5sum -c - <<< "b8d005a2be0bf58137ac46726d443365 *html/changelogs/example.yml"
python3 tools/GenerateChangelog/ss13_genchangelog.py html/changelog.html html/changelogs
