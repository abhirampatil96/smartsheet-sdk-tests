# smartsheet-diff-extension
This is a WireMock extension to provide diff responses in the form of Smartsheet errors. When a request fails to match a mapping, the diff extension will perform a comparison between the request and the specified scenario.

1. Build the smartsheet custom WireMock diff extension

    1. cd into wiremock/smartsheet-diff-extension folder

    2. Build the extension JAR

    ```
    ./gradlew clean shadowJar
    ```

    This will create a JAR in the build/libs directory

    3. Copy the JAR to sdk_tests_package/libs directory

    This directory is used by the package.sh script

2. Run npm install from the root of the repository
```
npm install
```

3. Run package.sh script from the root of the repository
```
./package.sh
```
