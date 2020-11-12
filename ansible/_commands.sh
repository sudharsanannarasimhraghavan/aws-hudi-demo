
ansible-playbook main.yml
ansible-playbook z_main.yml
ansible-playbook z_main-minikube.yml


ansible-playbook

# "SubnetsPrivate": "subnet-03cc5f6be3602809c,subnet-04fc420b39441b7c1,subnet-0e2fe024c02b6e6ae",
# "SubnetsPublic": "subnet-0f353606c2002d465,subnet-089725fc3cd4b3e0a,subnet-09eb7df5a2d9b07ba",

brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
brew upgrade eksctl


ansible-playbook main.yml -e "deployment_env=prod nocyberark=1 nodataload=1"

# create a new role
ansible-galaxy role init <your new role>


ansible-playbook main.yml -e "deployment_env=aia"