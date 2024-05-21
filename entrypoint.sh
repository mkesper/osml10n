#!/bin/bash

set -eu -o pipefail

echo "Running from: $(pwd)"
. venv/bin/activate
python /usr/bin/geo-transcript-srv.py -b 0.0.0.0
