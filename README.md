Encryption: openssl enc -aes-256-cbc -e -in [input path/file] -out [output path/file]

Decryption:  openssl enc -aes-256-cbc -d -in [input path/file] -out [output path/file]

openssl enc -aes-256-cbc -e -in ssh/id_rsa -out ssh/id_rsa.enc
openssl enc -aes-256-cbc -e -in ssh/id_rsa.pub -out ssh/id_rsa.pub.enc
openssl enc -aes-256-cbc -e -in zshenv -out zshenv -pass file:.pass
