FROM node:24-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-venv \
    && rm -rf /var/lib/apt/lists/* && python3 -m venv /opt/tracker-python
WORKDIR /app
COPY requirements.txt .
RUN /opt/tracker-python/bin/pip install --no-cache-dir -r requirements.txt
COPY package.json .
COPY worker/ worker/
COPY standalone/ standalone/
COPY drizzle/ drizzle/
RUN npm run build && install -d -o node -g node /data
ENV TRACKER_PYTHON=/opt/tracker-python/bin/python TRACKER_HOST=0.0.0.0 TRACKER_DB=/data/tracker.sqlite PORT=3000
USER node
EXPOSE 3000
CMD ["node", "standalone/server.mjs"]
