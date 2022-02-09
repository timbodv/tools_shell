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

WORKDIR /temp-work-dir

##############################################
# Azure tools
##############################################

RUN echo $'[azure-cli] \n\
name=Azure CLI \n\
baseurl=https://packages.microsoft.com/yumrepos/azure-cli \n\
enabled=1 \n\
gpgcheck=1 \n\
gpgkey=https://packages.microsoft.com/keys/microsoft.asc' | sudo tee /etc/yum.repos.d/azure-cli.repo &&\
    sudo dnf install -y azure-cli \
                        dotnet-sdk-6.0.x86_64

RUN az extension add --system --name ssh -y

RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 \
  && chmod +x ./bicep \
  && sudo cp ./bicep /usr/local/bin/bicep

ENV DOTNET_CLI_TELEMETRY_OPTOUT true
ENV DOTNET_NOLOGO true

# command executable and version
CMD ["-nologo"]
ENTRYPOINT ["pwsh"]
