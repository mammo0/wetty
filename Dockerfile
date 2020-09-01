FROM arm32v7/node:dubnium-alpine as builder
RUN apk add -U build-base python
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN yarn && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline

FROM arm32v7/node:dubnium-alpine
LABEL maintainer="butlerx@notthe.cloud"
LABEL maintainer="marc.ammon@fau.de"

ENV PORT=3000
ENV SSHHOST=localhost
ENV SSHPORT=22

WORKDIR /usr/src/app
ENV NODE_ENV=production
EXPOSE $PORT
COPY --from=builder /usr/src/app/dist /usr/src/app/dist
COPY --from=builder /usr/src/app/node_modules /usr/src/app/node_modules
COPY package.json /usr/src/app
COPY index.js /usr/src/app
RUN apk add -U openssh-client sshpass && \
    mkdir ~/.ssh && \
    echo '#!/usr/bin/env sh' > /entrypoint.sh && \
    echo 'node .' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
