#!/usr/bin/env bash
set -euo pipefail
log() { echo -e "\n[+] $*"; }
warn() { echo -e "\n[!] $*" >&2; }
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/00-common.env"
log "Configuring Apache lab pages..."
mkdir -p /var/www/html
cat >/var/www/html/result.html <<'EOF'
<html>
<head>
<title> Result from upload </title>
</head>
<body>
File Upload Processed!
</body>
</html>
EOF
cat >/var/www/html/fileupload.html <<'EOF'
<html>
<head>
<title> Test for file upload DLP Lab </title>
</head>
<body>
<h2>File upload test</h2>
<form action="result.html" method="post" enctype="multipart/form-data">
  Select file to upload:
  <input type="file" name="fileToUpload" id="fileToUpload">
  <input type="submit" value="Upload File" name="submit">
</form>
</body>
</html>
EOF
systemctl enable --now apache2
log "Done."
