FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

RUN flutter config --enable-web && flutter doctor -v

COPY pubspec.yaml ./
RUN flutter pub get || true

COPY . .

EXPOSE 8081

ENV FLUTTER_ANALYTICS_LOG_FILE=/dev/null

CMD ["bash", "-lc", "flutter pub get && flutter run -d web-server --web-port 8081 --web-hostname 0.0.0.0"]
