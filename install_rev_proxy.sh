#! /usr/bin/sh

# source parameters.txt file
. ./parameters.txt

### Test internet connection

ping -c 2 google.com  &> /dev/null
  if [ $? -eq 0 ]; then
      echo "ping is ok"
  else
      echo "Ping to google.com failed. You msut be connected to the public internet before using this tool to install reverse-proxy."
      echo "The tool needs to install ansible and nginx packages"
      exit
  fi

echo "#############################"
echo "Installng Reverse-proxy server"
echo "#############################"

# Find OS type and OS Level
OS=`cat /etc/os-release | grep ^ID= | awk -F\" {'print $2}'`

if [ "$OS" = "rhel" ] || [ "$OS" = "centos" ] || [ "$OS" = "rocky" ]
then
   VER=`cat /etc/os-release | grep VERSION_ID | awk -F\" {'print $2}' | awk -F. {'print $1}'`
   SUB=`cat /etc/os-release | grep VERSION_ID | awk -F\" {'print $2}'`
   if [ $VER -lt 8 ]
   then
         echo ##############################################
         echo "System runs on OS = $OS and Version = $SUB";
         echo ##############################################
         yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#         subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"  --enable "rhel-ha-for-rhel-*-server-rpms"
         yum -y install epel-release
         yum -y upgrade
         yum -y install python36
         yum  list nginx | grep nginx &> /dev/null
             if [ $? -eq 0 ]; then
                 echo "nginx is in yum repo"
                 yum -y install nginx
             else
                 echo "nginx is not in yum repo. Installing nginx repo first and then running yum command"
             fi

         yum list ansible | grep ansible &> /dev/null
             if [ $? -eq 0 ]; then
                 echo "Ansible is in yum repo"
                 yum -y install ansible
             else
                 echo "nginx is not in yum repo. Installing ansible via PIP3"
                 pip3 install --user ansible 
             fi
         yum -y upgrade
   elif [ $VER -lt 9 ]
   then
         echo ##############################################
         echo "System runs on OS = $OS and Version = $SUB";
         echo ##############################################
         yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
#         ARCH=$( /bin/arch );subscription-manager repos --enable "codeready-builder-for-rhel-8-${ARCH}-rpms"
#         dnf config-manager --set-enabled powertools
         yum -y install epel-release
         yum -y upgrade
         yum -y install python36
         yum  list nginx | grep nginx &> /dev/null
             if [ $? -eq 0 ]; then
                 echo "nginx is in yum repo"
                 yum -y install nginx
             else
                 echo "nginx is not in yum repo. Installing via ansible playbook via installing nginx repo first"
             fi

         yum  list ansible | grep ansible &> /dev/null
             if [ $? -eq 0 ]; then
                 echo "Ansible is in yum repo. Instaling with yum"
                 yum -y install ansible
             else
                 echo "ansible is not in yum repo. Installing via PIP3"
                 pip3 install --user ansible 
             fi
         yum -y upgrade

   elif [ $VER -lt 10 ]
   then

         echo ##############################################
         echo "System runs on OS = $OS and Version = $SUB";
         echo ##############################################
         yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
#         ARCH=$( /bin/arch );subscription-manager repos --enable "codeready-builder-for-rhel-8-${ARCH}-rpms"
#         dnf config-manager --set-enabled powertools
         yum -y install epel-release
         yum -y upgrade
         yum -y install python36
         yum  list nginx | grep nginx &> /dev/null
             if [ $? -eq 0 ]; then
                 echo "nginx is in yum repo"
                 yum -y install nginx
             else
                 echo "nginx is not in yum repo. Installing via ansible playbook via installing nginx repo first"
             fi

         yum  list ansible | grep ansible &> /dev/null
             if [ $? -eq 0 ]; then
                 echo "Ansible is in yum repo. Instaling with yum"
                 yum -y install ansible
             else
                 echo "ansible is not in yum repo. Installing via PIP3"
                 pip3 install --user ansible
             fi
         yum -y upgrade
   fi


        ### Continue with ansible role

        mkdir -p /etc/ansible
        touch /etc/ansible/ansible.cfg
        touch /etc/ansible/hosts
        echo  "[defaults]" > /etc/ansible/ansible.cfg
        echo  "ansible_python_interpreter=/usr/bin/python3.6" >> /etc/ansible/ansible.cfg
        echo  hostname > /etc/ansible/hosts

        echo "##############################################################"
        echo "STARTING Ansible Playbook to configure nginx"
        echo "###############################################################"

        ansible-playbook rev_prox_role.yml --extra-vars "COS_ENDPOINT_URL=$cos_endpoint PASSWORD=$password ENCRYPT=$encrypt RSA=$rsa FQDN=$FQDN ORGNAME=$ORGNAME SSL_EXPIRE=$ssl_expire"

        #########################################################################################################
        echo
        echo
        echo "This is your  acstest.crt file which is located in the home directory. This file is to be used to configure IBM i servers"
        echo "You will need to now install AWS cli or S3CMD cli to use this reverse proxy via a CLI command"
        echo "You can install AWS cli via yum install awscli command if you have internet access"
        echo "Also you need to configure AWS cli via aws configure command and enter your COS HMAC credentials"
        echo "**********************************************************"
        echo
        echo "You can now issue an aws command to access the COS bucket"
        echo
        echo "For Example:"
        echo  "aws --no-verify-ssl --endpoint-url https://<reverse-proxy private IP> s3 ls"
        echo
        cat ~/acstest.crt

else
    echo "This OS is not supported. We only supprt REHL/CentoOS/Rocky versions 7 and 8"
fi

