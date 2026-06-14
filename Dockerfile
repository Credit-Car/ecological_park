# ==========================================
# Stage 1: Build the Flutter Web Application
# ==========================================
# We use a reliable, pre-built community image that contains the Flutter SDK
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set the working directory inside the container
WORKDIR /app

# Copy pubspec files first to cache dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of your application code
COPY . .

# Build the web application in release mode
RUN flutter build web --release

# ==========================================
# Stage 2: Serve the App using Nginx
# ==========================================
# We use a tiny, lightweight web server image
FROM nginx:alpine

# Copy the custom Nginx configuration we made in Step 2
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the compiled static files from Stage 1 into the Nginx server directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 inside the container
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]