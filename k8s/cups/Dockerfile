FROM anujdatar/cups:latest

RUN apt-get update && \
    apt-get install -y wget
RUN wget \
      --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0" \
      --referer="https://download-center.epson.com" \
      -O /tmp/epson-driver.deb \
      "https://download-center.epson.com/f/module/fccea047-d7ce-4f47-a58b-3126090293b1/epson-inkjet-printer-201401w_1.0.1-1_amd64.deb"
RUN apt-get install -y avahi-daemon avahi-utils libnss-mdns /tmp/epson-driver.deb && \
    rm /tmp/epson-driver.deb && \
    apt-get remove -y wget && apt-get clean
COPY --chmod=755 --chown=root entrypoint.sh /entrypoint.sh