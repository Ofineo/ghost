FROM ghost:5-alpine as cloudinary

USER root
WORKDIR $GHOST_INSTALL

RUN apk add --no-cache g++ make python3

# Install storage adapter
RUN npm install ghost-storage-cloudinary


# ---------- Final Image ----------
FROM ghost:5-alpine

COPY --chown=node:node --from=cloudinary \
    $GHOST_INSTALL/node_modules \
    $GHOST_INSTALL/node_modules

COPY --chown=node:node --from=cloudinary \
    $GHOST_INSTALL/node_modules/ghost-storage-cloudinary \
    $GHOST_INSTALL/content/adapters/storage/ghost-storage-cloudinary

# Configure Ghost (run as node user)
USER node

RUN ghost config storage.active ghost-storage-cloudinary && \
    ghost config storage.ghost-cloudinary.upload.use_filename true && \
    ghost config storage.ghost-cloudinary.upload.unique_filename false && \
    ghost config storage.ghost-cloudinary.upload.overwrite false && \
    ghost config storage.ghost-cloudinary.fetch.quality auto && \
    ghost config storage.ghost-cloudinary.fetch.cdn_subdomain true && \
    ghost config mail.transport SMTP && \
    ghost config mail.options.service Mailgun
