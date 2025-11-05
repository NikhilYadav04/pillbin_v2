# Use an official lightweight Node.js runtime (Alpine)
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json from your 'server' directory
# We copy these first to take advantage of Docker's layer caching.
# The 'package-lock.json*' wildcard ensures it copies if it exists.
COPY server/package.json server/package-lock.json* ./

# Install only the production dependencies
RUN npm install --production

# Copy all the source code from your 'server' directory into the container's working directory
COPY server/ .

# Your server.js listens on process.env.PORT || 5000.
# Railway will automatically set the PORT environment variable.
# We expose 5000 as a fallback, but Railway will handle the mapping.
EXPOSE 5000

# The command to run your application in production.
# We use 'node server.js' instead of 'nodemon' for a production environment.
CMD ["node", "server.js"]