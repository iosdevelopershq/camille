# 1
FROM swift:5.5
WORKDIR /app
COPY . .

# 2
RUN apt-get update && apt-get install libsqlite3-dev

# 3
RUN swift package clean
RUN swift build

# 4
RUN mkdir /app/bin
RUN mv `swift build --show-bin-path` /app/bin

# 5
EXPOSE 8080
ENTRYPOINT ./bin/debug/Camille serve --env local --hostname 0.0.0.0
