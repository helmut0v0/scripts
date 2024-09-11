#!/bin/bash
  
#[ ${pkg_manage:=$(command -v yum)} ] || [ ${pkg_manage:=$(command -v apt)} ] || (echo 'Unsupported Linux distributions' && exit 1)

if command -v yum > /dev/null; then
    yum install -y epel-release google-authenticator
    cp /etc/ssh/sshd_config{,.bak}
    cp /etc/pam.d/sshd{,.bak}
    sed -i \
        -e "s/^\ *[^\ *#]*\(ChallengeResponseAuthentication\|PasswordAuthentication\|PubkeyAuthentication\|UsePAM\|AuthenticationMethods\).*/#&/g" \
        -e "$ a ChallengeResponseAuthentication yes\nPasswordAuthentication no\nPubkeyAuthentication yes\nUsePAM yes\nAuthenticationMethods publickey,keyboard-interactive" /etc/ssh/sshd_config

    sed -i \
        -e "s/^\ *[^\ *#]*\(auth\ *substack\ *password-auth\|auth\ *required\ *pam_google_authenticator.so\)/#&/g" \
        -e "1 i auth required pam_google_authenticator.so" /etc/pam.d/sshd
elif command -v apt > /dev/null; then
    apt install -y libpam-google-authenticator
    cp /etc/ssh/sshd_config{,.bak}
    cp /etc/pam.d/sshd{,.bak}
    sed -i \
        -e "s/^\ *[^\ *#]*\(PermitRootLogin\|ChallengeResponseAuthentication\|KbdInteractiveAuthentication\|PasswordAuthentication\|PubkeyAuthentication\|UsePAM\|AuthenticationMethods\).*/#&/g" \
        -e "$ a PermitRootLogin yes\nKbdInteractiveAuthentication yes\nPasswordAuthentication no\nPubkeyAuthentication yes\nUsePAM yes\nAuthenticationMethods publickey,keyboard-interactive" /etc/ssh/ssh

    sed -i \
        -e "s/^\ *[^\ *#]*\(@include common-auth\|account\ *required\ *pam_nologin.so\|auth\ *required\ *pam_google_authenticator.so\)/#&/g" \
        -e "1 i auth required pam_google_authenticator.so nullok" /etc/pam.d/sshd
else
    echo 'Unsupported Linux distributions'
    exit 1
fi

systemctl restart sshd

#sed -i '/^[[:blank:]]*#*\(ChallengeResponseAuthentication\|PasswordAuthentication\|PubkeyAuthentication\|UsePAM\|AuthenticationMethods\).*/d' sshd_config

#sed -i '$a\ChallengeResponseAuthentication yes\nPasswordAuthentication no\nPubkeyAuthentication yes\nUsePAM yes\nAuthenticationMethods publickey,keyboard-interactive' sshd_config

#sed -i '/[[:blank:]]*pam_google_authenticator.so/d' sshd

#sed -i '1 i auth required pam_google_authenticator.so' sshd

#(cat /etc/ssh/ssh_config.bak | grep -v '^[[:space:]]*#*\(ChallengeResponseAuthentication\|PasswordAuthentication\|PubkeyAuthentication\|UsePAM\|AuthenticationMethods\).*'; echo -e 'ChallengeResponseAut

#(echo auth required pam_google_authenticator.so; cat /etc/pam.d/sshd.bak | grep -v '[[:space:]]*pam_google_authenticator.so') > /etc/pam.d/sshd

# auto generate code after install
google-authenticator -t -f -d -w 3 -r 3 -R 30
