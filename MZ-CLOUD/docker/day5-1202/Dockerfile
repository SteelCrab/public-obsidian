FROM ubuntu:24.04
RUN apt update && apt install iputils-ping net-tools iproute2 dnsutils -y \
&& apt upgrade -y \
&& apt clean \
&& rm -rf /var/lib/apt/lists/* 
CMD ["/bin/bash"]