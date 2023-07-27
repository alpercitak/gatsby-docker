FROM node:18-alpine AS build

WORKDIR /app
COPY . .

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

# Install make etc.
RUN apk add build-base

RUN yarn
RUN yarn build

FROM nginx:1.18-alpine AS deploy

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=build /app/public .
ENTRYPOINT ["nginx", "-g", "daemon off;"]
