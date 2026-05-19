#!/usr/bin/env bash

set -euo pipefail

project_path="${1:?Missing Xcode project path}"
scheme_name="${2:?Missing Xcode scheme name}"

simulator_line="$(
  xcodebuild -showdestinations \
    -project "$project_path" \
    -scheme "$scheme_name" \
  | grep -F "platform:iOS Simulator" \
  | grep -F "name:iPhone" \
  | head -n 1
)"

if [[ -z "$simulator_line" ]]; then
  echo "No iPhone simulator destination found." >&2
  exit 1
fi

simulator_id="$(printf '%s\n' "$simulator_line" | sed -nE 's/.*id:([^,}]+).*/\1/p')"
simulator_name="$(printf '%s\n' "$simulator_line" | sed -nE 's/.*name:([^,}]+).*/\1/p')"

if [[ -z "$simulator_id" ]]; then
  echo "Unable to parse simulator identifier from: $simulator_line" >&2
  exit 1
fi

echo "destination=id=$simulator_id"
echo "name=$simulator_name"
