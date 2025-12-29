SSL (Secure Sockets Layer)
- Legacy term to TLS (Transport Layer Security)
- Retired because had too many holes (POODLE attack)
- WHAT: security protocol, creates encrypted link between server and client
  - SSL Certificate as digital passport, its a file on the server that does 2 thigns:
    - Authentication
    - Encryption
- WHY: in HTTP, data is in plaintext, anyone can see sensitive data
  - SECURITY CIA: Confidentiallity, Integrity, Autheticity
  - SEO & Trust: Google discourages HTTP connections, browsers will also throw "Not Secure" warning
  - Compliance: PCI-DSS(payments), SOC2, HIPAA(health data) audits
- HOW: Asymetric Encryption (slow but secure for starts) & Symmetric Encryption (fast for actual data transfer)
  - STEP BY STEP:
    1. Client pings server, shows supported TLS versions and cipher suites
    2. Sever responds using the supported TLS version, gives SSL Certificate along with Public Key
    3. Browser authenticates the SSL certificate against trusted Certificate Authorities (CAs) like Let's Encrypt or DigiCert. If legit we move on.
    4. Browser generates a "Pre-master secret", encrypts it with server's Public Key and sends to server. Only server's private key can decrypt it. (Asymmetric, only in older RSA, newer ECDHE is more secure, provides Forward Secrecy)
    5. Both the client and the server now generate a Session Key (Symmetric) from that secret
    6. All future data is encrypted with this shared Session Key
        Asymmetric Encryption
        - X25519 - Elliptic Curve Diffie-Hellman
        - RSASSA-PSS
        Symmetric Encryption
		- AES_256

TLS (Transport Layer Security)
- WHAT: Direct successor to SSL
- Originally owned by Netscaped, but was taken over by IETF as a standardized internet protocol
- WHY: Total overhaul on security features of traditional SSL
- HOW: Improved efficiency (0-RTT) zero round trip time


