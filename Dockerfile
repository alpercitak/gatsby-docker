FROM node:22-alpine AS build-python

ENV PYTHONUNBUFFERED=1

# Install Python, pip, build tools, and venv support
RUN apk add --no-cache \
    python3 \
    py3-pip \
    py3-virtualenv \
    build-base \
    make \
    && ln -sf python3 /usr/bin/python

# Set up Python virtual environment (safe from PEP 668 restrictions)
RUN python3 -m venv /venv \
    && /venv/bin/pip install --upgrade pip setuptools

# Set PATH so pip/python from venv is used
ENV PATH="/venv/bin:$PATH"

FROM build-python AS build-gatsby

WORKDIR /app

# Install pnpm
RUN npm i -g pnpm

# Copy app
COPY . .

# Install dependencies and build
RUN pnpm install
RUN pnpm clean
RUN pnpm build

FROM nginx:1.29-alpine AS deploy

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=build-gatsby /app/public .
ENTRYPOINT ["nginx", "-g", "daemon off;"]
