FROM node:18-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
RUN npm run build

# serve with a small static server (e.g. serve) or nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
# configure nginx to set base path and allow proxy for /api if needed (ALB will route)
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
