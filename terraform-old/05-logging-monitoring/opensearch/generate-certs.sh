#!/bin/bash

k8s_pod="opensearch-cluster-master"
k8s_namespace="opensearch"
k8s_service="opensearch-cluster-master-headless"

# Root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -subj "/C=NL/ST=Noord-Holland/L=Hilversum/O=CyberComanne/OU=k8s/CN=cybercomanne.nl" -out root-ca.pem -days 3650
# Admin cert
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -subj "/C=NL/ST=Noord-Holland/L=Hilversum/O=CyberComanne/OU=k8s/CN=rcomanne" -out admin.csr
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem -days 3650

# Node cert
openssl genrsa -out node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node-key.pem
openssl req -new -key node-key.pem -subj "/C=NL/ST=Noord-Holland/L=Hilversum/O=CyberComanne/OU=k8s/CN=${k8s_pod}" -out node.csr

tee node.ext <<EOF
subjectAltName = @alt_names
[alt_names]
DNS.10 = ${k8s_pod}
EOF
for i in {0..2}; do
  echo "DNS.${i} = ${k8s_pod}-${i}.${k8s_service}.${k8s_namespace}.svc.cluster.local" >> node.ext
done

openssl x509 -req -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node.pem -days 3650 -extfile node.ext

# Cleanup
rm admin-key-temp.pem
rm admin.csr
rm node-key-temp.pem
rm node.csr
rm node.ext

kubectl create secret generic opensearch-certs --from-file root-ca.pem --from-file admin.pem --from-file admin-key.pem --from-file node.pem --from-file node-key.pem