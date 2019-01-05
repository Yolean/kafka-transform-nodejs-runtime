FROM yolean/node-kafka@sha256:f7aedb184d533cef7b4a88ea8520271f5912fedbc7016f0b5bb8daf29cd39907 \
  AS prod
WORKDIR /usr/src/runtime

COPY package*.json ./

RUN npm install --only=prod --no-shrinkwrap --no-optional

FROM yolean/node-kafka@sha256:f7aedb184d533cef7b4a88ea8520271f5912fedbc7016f0b5bb8daf29cd39907 \
  AS prepare
WORKDIR /usr/src/runtime

# Got no dependencies yet, so this fails
# COPY --from=prod /usr/src/runtime/node_modules/ ./node_modules/

COPY . .

RUN npm install --only=dev --no-shrinkwrap --no-optional

# Whatever produces something runnable
# Got no prepare script
# RUN npm run prepare

FROM yolean/node-kafka@sha256:f7aedb184d533cef7b4a88ea8520271f5912fedbc7016f0b5bb8daf29cd39907 \
  AS runtime
WORKDIR /usr/src/app

# Got no dependencies yet, so this fails
# COPY --from=prod /usr/src/runtime/node_modules/ WORKDIR /usr/src/runtime/node_modules/

# Whatever is needed at runtime
COPY --from=prepare /usr/src/runtime/package.json /usr/src/runtime/src /usr/src/runtime/

ENTRYPOINT [ "node", "/usr/src/runtime" ]

# The require
CMD [ "/usr/src/app" ]

# Now the handler developer should only need to copy prepared source and node_modules to /usr/src/app
