import pulumi, pulumi_tls

config = pulumi.Config()

# root ca
var_root_ca = config.require_object("root_ca")
res_root_ca_private_key = pulumi_tls.PrivateKey("root_ca", **var_root_ca["privateKey"])
res_root_ca_self_signed_cert = pulumi_tls.SelfSignedCert(
    "root_ca",
    private_key_pem=res_root_ca_private_key.private_key_pem,
    is_ca_certificate=True,
    **var_root_ca["selfSignedCert"]
)

# intermediate ca
var_int_ca = config.require_object("int_ca")
res_int_ca_private_key = pulumi_tls.PrivateKey("int_ca", **var_int_ca["privateKey"])
res_int_ca_cert_request = pulumi_tls.CertRequest(
    "int_ca",
    private_key_pem=res_int_ca_private_key.private_key_pem,
    subject=var_int_ca["cert"]["subject"],
)
res_int_ca_local_signed_cert = pulumi_tls.LocallySignedCert(
    "int_ca",
    cert_request_pem=res_int_ca_cert_request.cert_request_pem,
    ca_cert_pem=res_root_ca_self_signed_cert.cert_pem,
    ca_private_key_pem=res_root_ca_private_key.private_key_pem,
    is_ca_certificate=True,
    validity_period_hours=var_int_ca["cert"]["validity_period_hours"],
    allowed_uses=var_int_ca["cert"]["allowed_uses"],
)

# final certs
var_certs = config.require_object("certs")
for each_value in var_certs:
    res_cert_private_key = pulumi_tls.PrivateKey(
        each_value["name"], **each_value["key"]
    )
    res_cert_request = pulumi_tls.CertRequest(
        each_value["name"],
        private_key_pem=res_cert_private_key.private_key_pem,
        **each_value["request"]
    )
    res_cert_local_signed = pulumi_tls.LocallySignedCert(
        each_value["name"],
        cert_request_pem=res_cert_request.cert_request_pem,
        ca_cert_pem=res_int_ca_local_signed_cert.cert_pem,
        ca_private_key_pem=res_int_ca_private_key.private_key_pem,
        **each_value["sign"]
    )
