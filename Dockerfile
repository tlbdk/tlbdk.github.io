FROM node:22-alpine3.20 AS builder

# Copy in source files
RUN mkdir /app
WORKDIR /app
COPY . /app/

# Install dependencies and build project
RUN npm install
RUN npm run build

FROM scratch
COPY --from=builder /app/dist /
