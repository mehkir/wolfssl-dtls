#!/usr/bin/bash

printUsage() {
    printf "This tool generates certificates for SOME/IP services.\n"
    printf "Usage: $0 <service id> <instance id> <major version> <minor version> <ip address> <port> <protocol> <file name>\n"
    printf "Example: $0 1 2 3 4 172.17.0.3 30509 UDP h1\n"
}

if [[ $# -gt 7 ]]; then
    PROJECT_FOLDER_PATH="/home/mehmet/vscode-workspaces/wolfssl-dtls"
    CERTIFICATES_FOLDER_PATH="${PROJECT_FOLDER_PATH}/generated-certificates"
    service_id=$1
    instance_id=$2
    major_version=$3
    minor_version=$4
    ip_address=$5
    port_number=$6
    protocol_id=$7
    file_name=$8

    case $protocol_id in
        'UDP')
             protocol_id=17
             ;;
        'TCP')
             protocol_id=6
             ;;
        *)
            printf "Not supported protocol number.\n"
            exit 1
    esac

    #printf "service id: %s\n" "$service_id"
    #printf "instance id: %s\n" "$instance_id"
    #printf "major version: %s\n" "$major_version"
    #printf "minor version: %s\n" "$minor_version"

    dns_service=$(printf "0x%04x" $service_id)
    dns_instance=$(printf "0x%04x" $instance_id)
    dns_major=$(printf "0x%02x" $major_version)
    dns_minor=$(printf "0x%08x" $minor_version)

    CERTIFICATE_CONF="[ req ]
    prompt               = no
    default_bits         = 2048
    default_keyfile      = server-key.pem
    distinguished_name   = subject
    req_extensions       = req_ext
    x509_extensions      = x509_ext
    string_mask          = utf8only

    [ subject ]
    countryName          = DE
    stateOrProvinceName  = HH
    localityName         = Hamburg
    organizationName     = Hochschule fuer Angewandte Wissenschaften Hamburg
    commonName           = HAW Hamburg
    emailAddress         = mehmet.mueller@haw-hamburg.de

    [ x509_ext ]
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid,issuer
    basicConstraints        = critical,CA:FALSE
    keyUsage                = digitalSignature, keyEncipherment
    extendedKeyUsage        = clientAuth, serverAuth, secureShellServer
    subjectAltName          = @alternate_names
    nsComment               = \"OpenSSL Generated Certificate\"

    [ req_ext ]
    subjectKeyIdentifier    = hash
    basicConstraints        = critical,CA:FALSE
    keyUsage                = digitalSignature, keyEncipherment
    extendedKeyUsage        = clientAuth, serverAuth, secureShellServer
    subjectAltName          = @alternate_names
    nsComment               = \"OpenSSL Generated Certificate\"

    [ alternate_names ]
    DNS.1  = $(printf "_someip.minor%s.major%s.instance%s.id%s.service." "$dns_minor" "$dns_major" "$dns_instance" "$dns_service")
    DNS.2  = $(printf "_someip.major%s.instance%s.id%s.service."         "$dns_major" "$dns_instance" "$dns_service")
    DNS.3  = $(printf "_someip.minor%s.major%s.id%s.service."            "$dns_minor" "$dns_major" "$dns_service")
    DNS.4  = $(printf "_someip.instance%s.id%s.service."                 "$dns_instance" "$dns_service")
    DNS.5  = $(printf "_someip.major%s.id%s.service."                    "$dns_major" "$dns_service")
    DNS.6  = $(printf "_someip.id%s.service."                            "$dns_service")
    IP.1   = ${ip_address}
    email.1  = mehmet.mueller@haw-hamburg.de"

    cd ${CERTIFICATES_FOLDER_PATH}
    openssl req -config <(echo "$CERTIFICATE_CONF") -new -x509 -sha256 -newkey rsa:2048 -nodes -keyout "${file_name}.service.key.pem" -days 365 -out "${file_name}.service.cert.pem" 2>/dev/null
else
    printUsage
fi