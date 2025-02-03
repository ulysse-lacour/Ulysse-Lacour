# syntax=docker/dockerfile:1.4

####################################################################################################
## Directus install extensions

FROM directus/directus:11.2


USER root

# Install scripts dependencies and set scripts as executable
RUN apk add --no-cache sudo expect postgresql-client
COPY backup.sh /directus/backup.sh
RUN chmod +x /directus/backup.sh
COPY restore.sh /directus/restore.sh
RUN chmod +x /directus/restore.sh
COPY template.sh /directus/template.sh
RUN chmod +x /directus/template.sh

# Install pnpm and necessaries directus dependencies
ENV COREPACK_DEFAULT_TO_LATEST=0
RUN corepack enable \
    && corepack prepare pnpm@9.10 --activate

# Switch to node user for pnpm operations
USER node

# Workaround to be able to install extensions with 'node' user, only required in v11
RUN rm node_modules/.modules.yaml

EXPOSE ${PORT}

# Install extensions
RUN pnpm install \
    # https://github.com/directus-labs/directus-template-cli
    directus-template-cli@latest \
    typescript@latest \
    # https://github.com/tractr/directus-sync
    directus-extension-sync \
    directus-sync \
    # https://github.com/ChappIO/directus-extension-models
    directus-extension-models \
    # https://github.com/judahbsullivan/directus-auto-gen-extension
    directus-auto-gen-extension \
    # https://github.com/directus-labs/extensions/tree/main/packages/audio-player-interface
    @directus-labs/audio-player-interface \
    # https://github.com/directus-labs/extensions/tree/main/packages/video-player-interface
    @directus-labs/video-player-interface \
    # https://github.com/directus-labs/extensions/tree/main/packages/pdf-viewer-interface
    @directus-labs/pdf-viewer-interface \
    # https://github.com/directus-labs/extensions/tree/main/packages/card-select-interfaces
    @directus-labs/card-select-interfaces \
    # https://github.com/formfcw/directus-extension-classified-group
    directus-extension-classified-group \
    # https://github.com/directus-labs/extensions/tree/main/packages/experimental-m2a-interface
    @directus-labs/experimental-m2a-interface \
    # https://github.com/directus-labs/extensions/tree/main/packages/super-header-interface
    @directus-labs/super-header-interface \
    # https://github.com/directus-labs/extensions/tree/main/packages/switch-interface
    @directus-labs/switch-interface \
    # https://github.com/directus-labs/extensions/tree/main/packages/tour-group-interface
    @directus-labs/tour-group-interface \
    && pnpm config set auto-install-peers true

CMD : \
    && node /directus/cli.js bootstrap \
    && node /directus/cli.js start \
    ;
