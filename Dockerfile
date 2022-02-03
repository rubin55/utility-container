FROM debian:latest
SHELL ["/bin/bash", "-c"]
ENV PACKAGES_BLACKLIST "libbind-export-dev libcurl4-gnutls-dev libcurl4-nss-dev libeditreadline-dev libgnatvsn9-dev"
ENV DEBIAN_FRONTEND "noninteractive"
ENV PYTHONUNBUFFERED "true"
WORKDIR /tmp
RUN IFS=''; for line in $(cat /etc/apt/sources.list | grep -v '^#'); do echo $line ; echo $(echo $line | sed 's|^deb|deb-src|g'); done > sources.list && mv sources.list /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-utils 2> /dev/null
RUN apt-get install -y bind9-dnsutils bind9-host bison cmake curl flex gcc g++ iperf3 iproute2 iputils-ping jq ldap-utils make man-db net-tools netcat nmap openssl postgresql-client-common python-is-python3 python3 python3-pip python3-venv python3-wheel tcpdump traceroute vim
RUN for package in $(dpkg-query -f '${Package}\n' -W | grep -v '\-dev'); do candidate="$(apt-cache showsrc $package | grep 'libdevel' | grep 'arch=any' | head -n1 | awk '{print $1}')"; if [[ -n "$candidate" && ! "$PACKAGE_BLACKLIST" =~ "$candidate" ]]; then echo "$candidate"; fi; done | sort -u > devpkgs.list
RUN apt-get install -y $(cat devpkgs.list) && rm devpkgs.list
EXPOSE 8000/tcp
ENTRYPOINT ["python", "-m", "http.server"]
