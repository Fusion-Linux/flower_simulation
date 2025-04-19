# Use an official Python runtime as a parent image
FROM python:3.11-slim-buster

# Set the working directory in the container to /app
WORKDIR /app

# Copy all requirements files
COPY ./requirements.txt /app/requirements.txt
COPY ./result_requirements.txt /app/result_requirements.txt

# Install gcc and other dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    pkg-config \
    libhdf5-dev \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

# Install both training and reporting packages
RUN pip install --no-cache-dir -r requirements.txt -r result_requirements.txt

# Copy the report generation scripts
COPY result_script.sh /app/
COPY generate_report.py /app/

# Make report script executable
RUN chmod +x /app/result_script.sh

# Copy the rest of the application code
COPY . /app/

# Default command will be overridden by docker-compose service definitions
CMD ["python", "server.py"]
