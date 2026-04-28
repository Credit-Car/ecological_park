# --- Stage 1: Build the Web App ---
FROM ghcr.io/cirruslabs/flutter:stable AS build

# 1. Create the 'flutter' user and fix SDK permissions
USER root
RUN useradd -m flutter && \
    chown -R flutter:flutter /sdks/flutter

# 2. Switch to the flutter user
USER flutter
WORKDIR /home/flutter/app

# 3. Copy pubspec and get dependencies
COPY --chown=flutter:flutter pubspec.* ./
RUN flutter pub get

# 4. Copy code
COPY --chown=flutter:flutter . .

# ADD THESE TWO LINES TO DEBUG:
RUN flutter clean
RUN flutter pub get

# 5. Build for web
RUN flutter build web --release

# --- Stage 2: Serve with Nginx ---
FROM nginx:alpine

# Copy the built web assets from the build stage to Nginx
COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html

# Expose port 80 (Standard web port)
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]