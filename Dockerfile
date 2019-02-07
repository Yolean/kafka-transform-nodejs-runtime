FROM solsson/node-kafkacat@sha256:aa51a23635201191004dbe5ef6eefaf3d4c15728e2072ab88e1aa75525e20f5d \
  AS prod
WORKDIR /usr/src/runtime

COPY package*.json ./

RUN npm install --only=prod --no-shrinkwrap --no-optional

FROM yolean/node-kafka-cache@sha256:3d7d916c084ae96e34633947b902fbcaef00de3b77f873a482935575459e1f5b \
  AS prepare
WORKDIR /usr/src/runtime

# Got no dependencies yet, so this fails
# COPY --from=prod /usr/src/runtime/node_modules/ ./node_modules/

COPY . .

RUN npm install --only=dev --no-shrinkwrap --no-optional

# Whatever produces something runnable, but we have no such thing yet
# RUN npm run prepare

FROM yolean/node-kafka-cache@sha256:3d7d916c084ae96e34633947b902fbcaef00de3b77f873a482935575459e1f5b \
  AS runtime
WORKDIR /usr/src/app

# Got no dependencies yet, so this fails
# COPY --from=prod /usr/src/runtime/node_modules/ WORKDIR /usr/src/runtime/node_modules/

# Whatever is needed at runtime
COPY --from=prepare /usr/src/runtime/ /usr/src/runtime/

RUN node -p "require('node-rdkafka')"

ENTRYPOINT [ "/usr/src/runtime/kafkacat.sh", "/usr/src/runtime" ]

# The require
CMD [ "/usr/src/app" ]

# Now the handler developer should only need to copy prepared source and node_modules to /usr/src/app
