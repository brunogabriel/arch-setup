#!/bin/bash

# mise_installs/java.sh
# Java installation via mise (Eclipse Temurin recommended)

readonly JAVA_DEFAULT_VERSION="temurin-25.0.2+10.0.LTS"

_java_post_install() {
    smart_append_to_zsh "shell" \
        'export JAVA_HOME="$(mise where java 2>/dev/null)"' \
        "Java - JAVA_HOME"
}

install_java() {
    mise_install_language \
        --name         "Java" \
        --package      "java" \
        --default      "$JAVA_DEFAULT_VERSION" \
        --placeholder  "e.g., temurin-21.0.5+11.0.LTS, graalvm-21, corretto-21" \
        --description  "Temurin is the recommended OpenJDK distribution (open-source, LTS)" \
        --post-install "_java_post_install" \
        --version-cmd  "java -version 2>&1"
}
