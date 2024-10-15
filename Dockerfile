# Dockerfile
FROM gcc:latest

# Set the working directory
WORKDIR /app

# Copy the source files
COPY . .

# Install any necessary libraries (e.g., Boost)
RUN apt-get update && \
    apt-get install -y libboost-all-dev && \
    g++ -o myapp main.cpp -lboost_system -lboost_filesystem

# Command to run the application
CMD ["./myapp"]
