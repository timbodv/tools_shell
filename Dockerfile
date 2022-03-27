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

##############################################
# AWS tools
##############################################

RUN sudo dnf install -y unzip \
                        less \
                        groff \
                        glibc \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install

##############################################
# PowerShell modules
##############################################

COPY ./installPowerShellModules.ps1 /temp-work-dir

RUN /usr/bin/pwsh -File ./installPowerShellModules.ps1

##############################################
# Other tools
##############################################

# fx https://github.com/antonmedv/fx/releases
RUN curl -L "https://github.com/antonmedv/fx/releases/download/20.0.2/fx-linux.zip" -o "fx-linux.zip" \
    && unzip ./fx-linux.zip \
    && chmod +x ./fx-linux \
    && sudo cp ./fx-linux /usr/local/bin/fx

RUN sudo dnf install -y pandoc \
                        aria2 \
                        jq \
                        git \
                        gnutls-utils \
                        mtr \
                        sshpass

# Terraform, Vault, and Packer
RUN sudo dnf install -y dnf-plugins-core \
    && sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo \
    && sudo dnf -y install terraform packer vault
    && setcap -r /usr/bin/vault

# Ansible with the Azure addins
RUN sudo dnf install -y pip

RUN pip3 install virtualenv \
  && cd /opt \
  && virtualenv -p python3 ansible \
  && /bin/bash -c "source ansible/bin/activate && pip3 install ansible && pip3 install pywinrm>=0.2.2 && deactivate" \
  && /opt/ansible/bin/ansible-galaxy collection install azure.azcollection

RUN wget -nv -q https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt \
    && /opt/ansible/bin/python -m pip install -r requirements-azure.txt \
    && rm requirements-azure.txt

ENV PATH="/opt/ansible/bin:${PATH}"

# Java SDK is handy sometimes
RUN sudo dnf install -y java-11-openjdk-headless

WORKDIR /

RUN rm -r temp-work-dir/

CMD ["-nologo"]
ENTRYPOINT ["pwsh"]
