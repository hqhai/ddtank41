# All-in-one game image: Center/Fighting/Road servers (Mono), web portal + Request API
# (fastcgi-mono-server4 behind nginx), Flash client + resources, Ruffle and the websocket bridge.
# Build context = repository root:   docker build -f deploy/docker/Dockerfile -t ddtank41 .
# Normally used through deploy/docker/docker-compose.yml.

# ---- build stage: compile with the .NET SDK and download the resource site ----
FROM ubuntu:24.04 AS build
ENV DEBIAN_FRONTEND=noninteractive DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
RUN apt-get update && apt-get install -y --no-install-recommends \
      dotnet-sdk-8.0 git python3 curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . .
RUN deploy/build-server.sh /out/server && deploy/build-web.sh /out/web
RUN deploy/fetch-resources.sh /out/site \
    && OUT=/out deploy/setup.sh assemble

# ---- runtime stage ----
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      mono-runtime mono-complete mono-fastcgi-server4 nginx libnginx-mod-http-perl websockify \
      tmux python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /ddtank/deploy
COPY deploy/configure.py deploy/server.env.example ./
COPY deploy/linux ./linux
COPY deploy/sql ./sql
COPY --from=build /out ./out
COPY deploy/docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh linux/*.sh
EXPOSE 80 9500 9501
ENTRYPOINT ["/entrypoint.sh"]
