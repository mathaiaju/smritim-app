# =========================
# 1️⃣ Build stage
# =========================

FROM ghcr.io/cirruslabs/flutter:stable AS build


WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# =========================
# 2️⃣ Runtime stage
# =========================
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy Flutter build
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
