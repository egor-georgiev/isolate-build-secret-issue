FROM busybox

ARG ENV_FILE_WORKS
RUN --mount=type=secret,id=my_secret_name \
    --mount=type=secret,id=my_secret_value \
    echo "env file works, because this env var is being picked up from the env file: ${ENV_FILE_WORKS}" \
    && ls -la /run/secrets/ \
    && cat /run/secrets/* \

