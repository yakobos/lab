# curl
# git


# k3s
curl -sfL https://get.k3s.io | sh -
# gets rid of need to use sudo for kubectl
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

# install git
# git PAT
# create PAT
# set GITHUB_USER
# set GITHUB_TOKEN

# flux cd
curl -s https://fluxcd.io/install.sh | sudo bash
flux --pre
# add auth-token so https is used instaead of ssh
flux bootstrap github --owner=$GITHUB_USER --repository=cluster --branch=main --path=./clusters/staging --personal --auth-token
# requires PAT entered manually


kubectl port-forward pod/linkding-ASSADFASDSAFASD -n linkding 8080:9090


# kubens


# setup first linkding user
kubectl exec -it <linkding_pod_name> -- python manage.py createsuperuser --username=<USERNAME> --email=<EMAIL>

# exposing linkding to the internet
# create a cloudflare tunnel on cloudflare gui, just pay for a domain
# install cloudflared
cloudflared tunnel login
cloudflared tunnel create <tunnel_name>
kubectl create secret generic tunnel-credentials \
	--from-file=credentials.json=/homedir/.cloudflared/<tunnel_id>.json \
	--from-file=cert.pem=/homedir/.cloudflared/cert.pem
# go to cloudflare DNS, add new CNAME record, and enter <tunnel_id>.cfargotunnel.com
# create service manifest
# create deployment manifest
#       my deployment differed from mischas in that i needed the extra cert.pem
# create configmap manifest

# tree
# kubectx
# 
#
# Github Personal Access Token
