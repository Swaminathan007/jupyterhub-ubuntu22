FROM ubuntu:22.04

# Set work directory
WORKDIR /app/analysis

# System dependencies
RUN apt update && apt install -y \
    build-essential \
    wget \
    curl \
    sudo \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    git \
    openssl \
    python3-virtualenv \
    python3-pip \
    unzip \
    libffi-dev \
    liblzma-dev 

RUN curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install -y nodejs

# Confirm
RUN node -v 
RUN npm -v

RUN pip3 install --upgrade pip

# Install Python libraries

RUN python3 -m pip install jupyterhub
RUN npm install -g configurable-http-proxy
RUN python3 -m pip install jupyterlab notebook tensorflow pandas scikit-learn numpy polars torch

# Install JupyterHub configurable HTTP proxy
RUN npm install -g configurable-http-proxy

# Create admin user
RUN useradd -m admin && echo admin:change.it! | chpasswd && mkdir -p /home/admin && chown admin:admin /home/admin

# Generate self-signed certificate
RUN mkdir -p /etc/jupyterhub/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/jupyterhub/ssl/jupyterhub.key \
    -out /etc/jupyterhub/ssl/jupyterhub.crt \
    -subj "/C=US/ST=State/L=City/O=Org/OU=IT/CN=localhost"

# Add config and user creation script
COPY jupyterhub_config.py /app/analysis/jupyterhub_config.py
COPY create-new-user.py /app/analysis/create-new-user.py

# Expose JupyterHub HTTPS port
EXPOSE 8000

# Run JupyterHub with SSL
CMD ["jupyterhub", "--ip=0.0.0.0", "--port=8000", \
     "--ssl-key=/etc/jupyterhub/ssl/jupyterhub.key", \
     "--ssl-cert=/etc/jupyterhub/ssl/jupyterhub.crt"]
