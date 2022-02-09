FROM fedora:35

RUN sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&\
    curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo &&\
    sudo dnf upgrade -y &&\
    sudo dnf install -y powershell \
                        unzip \
                        less \
                        nano \
                        wget \
                        zip \
                        groff \
                        glibc

ENV POWERSHELL_UPDATECHECK Off
ENV POWERSHELL_TELEMETRY_OPTOUT true

# command executable and version
CMD ["-nologo"]
ENTRYPOINT ["pwsh"]
