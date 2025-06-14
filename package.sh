#!/usr/bin/env sh

# exit on error
set -e

PACKAGE_NAME='sdk_tests_package'
EXTENSION_JAR_FILENAME='diff-extension.jar'
EXTENSION_JAR="$PACKAGE_NAME/libs/$EXTENSION_JAR_FILENAME"
DATA_SCENARIO_DIR='data/scenarios'
LAUNCH_SCRIPT='data/launch.sh'
PACKAGE_README='data/README.md'
STUB_DEFAULTS='data/stub_defaults.json'

if [ $# -eq 1 ]; then
    EXTENSION_JAR=$1
fi

if [ -z "$EXTENSION_JAR" ] || [ ! -f "$EXTENSION_JAR" ]; then
    echo 'Usage: $0 [diff-extension.jar]'
    echo "    diff-extension.jar - Optional, uses jar in package by default: $PACKAGE_NAME/libs/$EXTENSION_JAR_FILENAME"
    echo ''
    echo 'ERROR: Could not find extension JAR'

    exit 1
fi

PACKAGE_MAPPINGS_DIR="$PACKAGE_NAME/mappings/"
PACKAGE_SCENARIO_DIR="$PACKAGE_NAME/__files/__scenarios/"
PACKAGE_SCENARIOS="$PACKAGE_SCENARIO_DIR/scenarios.json"
TMP_SCENARIOS=".tmp_scenarios.json"

# make wiremock root directory
mkdir -p "$PACKAGE_SCENARIO_DIR"
mkdir -p "$PACKAGE_MAPPINGS_DIR"
echo 'Package directories created'

# add scenario and apply defaults
node concat_scenarios.js --scenarios="$DATA_SCENARIO_DIR" --output="$TMP_SCENARIOS"
echo 'Scenarios concatenated'

node apply_defaults.js --output="$PACKAGE_SCENARIOS" --defaults="$STUB_DEFAULTS" --scenarios="$TMP_SCENARIOS"
rm "$TMP_SCENARIOS"
echo 'Defaults applied'

# add mappings
node gen_mappings.js --scenarios="$PACKAGE_SCENARIOS" --output_dir="$PACKAGE_MAPPINGS_DIR"
echo 'Mappings generated'

# add readme
cp "$PACKAGE_README" "$PACKAGE_NAME/README.md"
node gen_docs.js --scenarios="$PACKAGE_SCENARIOS" >> "$PACKAGE_NAME/README.md"
echo 'Docs generated'

# add wiremock extension JAR and dependencies
mkdir -p "$PACKAGE_NAME/libs"
if [ "$EXTENSION_JAR" != "$PACKAGE_NAME/libs/$EXTENSION_JAR_FILENAME" ]; then
  cp "$EXTENSION_JAR" "$PACKAGE_NAME/libs/$EXTENSION_JAR_FILENAME"
fi
echo 'Wiremock diff extension included'

# Download required dependencies if they don't exist
LIBS_DIR="$PACKAGE_NAME/libs"
MAVEN_CENTRAL="https://repo1.maven.org/maven2"

# Function to download dependency if it doesn't exist
download_dependency() {
    local filename=$1
    local url=$2

    if [ ! -f "$LIBS_DIR/$filename" ]; then
        echo "Downloading $filename..."
        curl -L -o "$LIBS_DIR/$filename" "$url"
        echo "$filename downloaded"
    else
        echo "$filename already exists"
    fi
}

# Download JAXB API
download_dependency "jaxb-api.jar" "$MAVEN_CENTRAL/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar"

# Download JAXB Core
download_dependency "jaxb-core.jar" "$MAVEN_CENTRAL/com/sun/xml/bind/jaxb-core/4.0.3/jaxb-core-4.0.3.jar"

# Download JAXB Runtime (jaxb-impl)
download_dependency "jaxb-runtime.jar" "$MAVEN_CENTRAL/com/sun/xml/bind/jaxb-impl/4.0.3/jaxb-impl-4.0.3.jar"

# Download WireMock Standalone
download_dependency "wiremock-standalone.jar" "$MAVEN_CENTRAL/org/wiremock/wiremock-standalone/3.0.1/wiremock-standalone-3.0.1.jar"

echo 'All dependencies included'

# add launch script
cp "$LAUNCH_SCRIPT" "$PACKAGE_NAME/launch.sh"
echo 'Launch script added'

echo 'Package complete'
