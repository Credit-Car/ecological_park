# # --- Stage 1: Build the Web App ---
# FROM ghcr.io/cirruslabs/flutter:stable AS build

# # 1. Setup permissions for the flutter user
# USER root
# RUN useradd -m flutter && \
#     chown -R flutter:flutter /sdks/flutter

# USER flutter
# WORKDIR /home/flutter/app

# # 2. Optimized Dependency layer (Caching)
# # We copy only these first so 'flutter pub get' isn't re-run 
# # unless your dependencies actually change.
# COPY --chown=flutter:flutter pubspec.yaml pubspec.lock ./
# RUN flutter pub get

# # 3. Copy the rest of the source code
# COPY --chown=flutter:flutter . .

# # 4. Build for web in release mode
# RUN flutter build web --release

# # --- Stage 2: Serve with Nginx ---
# FROM nginx:alpine

# # 5. Copy your custom Nginx config (critical for routing)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# # 6. Copy the built web assets from the build stage
# COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html

# # Standard web port
# EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]

# --- Stage 1: Build ---
FROM ghcr.io/cirruslabs/flutter:stable AS build
USER root
RUN useradd -m flutter && chown -R flutter:flutter /sdks/flutter
USER flutter
WORKDIR /home/flutter/app
COPY --chown=flutter:flutter pubspec.* ./
RUN flutter pub get
COPY --chown=flutter:flutter . .
RUN flutter build web --release

# --- Stage 2: Serve ---
FROM nginx:alpine
# Use a basic Nginx config that only handles Flutter routing
COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html
# We don't need the complex proxy logic here anymore!
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]