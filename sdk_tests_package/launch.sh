#!/usr/bin/env sh

MAIN_CLASS='wiremock.Run'

EXTENSION='ApiScenarioTransformer'

PORT=8082

# launch wiremock
java  -cp "libs/*" $MAIN_CLASS --extensions=$EXTENSION --port=$PORT
