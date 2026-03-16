#!/bin/bash

# EFA User Data Script
# Configures huge pages and EFA driver for high-performance ML/HPC workloads

# Configure huge pages for EFA workloads
echo "Configuring ${huge_pages_count} huge pages (2MiB each)..."
echo "vm.nr_hugepages = ${huge_pages_count}" >> /etc/sysctl.conf
sysctl -p

# Mount huge pages filesystem
mkdir -p /mnt/huge
echo "hugetlbfs /mnt/huge hugetlbfs defaults 0 0" >> /etc/fstab
mount -a

# Verify huge pages configuration
echo "Huge pages configuration:"
cat /proc/meminfo | grep -i huge

# Install EFA driver (if not already present in AMI)
if ! lsmod | grep -q efa; then
    echo "Installing EFA driver..."
    curl -O https://efa-installer.amazonaws.com/aws-efa-installer-latest.tar.gz
    tar -xf aws-efa-installer-latest.tar.gz
    cd aws-efa-installer
    ./efa_installer.sh -y
    cd ..
    rm -rf aws-efa-installer*
fi

# Load EFA driver
modprobe efa

# Verify EFA installation
echo "EFA driver status:"
lsmod | grep efa
fi_info -p efa || echo "EFA provider not found - this is expected if no EFA interfaces are attached yet"

echo "EFA configuration completed successfully"