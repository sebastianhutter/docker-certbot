# sebastianhutter/certbot

certbot container which creates certificates via aws route53

## configuration
configuration is done via environment variables or docker secrets.

-AWS_DEFAULT_REGION: the aws region for aws cli (defaults to: eu-central-1)
-AWS_ACCESS_KEY_ID: the aws access key
-AWS_SECRET_ACCESS_KEY: the aws access key secret
-DOMAIN: comma separated list of domains to register
-EMAIL: email used for registration and recovery contact for certbot

### docker secrets
to use docker secrets instead of environment variables simply store the path to the secrets file for the specific variable in the environment variable.

for example:

my secret access key is stored in the docker secret `aws-secret`. to use the value from the file I can specify the full path inside the environment variable.

```
-e  AWS_SECRET_ACCESS_KEY=/run/secrets/aws-secret
```

## usage
see the official certbot docker documentation https://certbot.eff.org/docs/install.html#running-with-docker.
It is important to have /etc/letsencrypt in its own persistent volume!

to create a certificate for the domain "testdomain.hutter.cloud" execute the following command:
```
docker run -ti --rm -v letsencrypt-etc:/etc/letsencrypt \
    -e AWS_ACCESS_KEY_ID=/run/secrets/key \
    -e AWS_SECRET_ACCESS_KEY=/run/secrets/secret \
    -e DOMAIN=testdomain.hutter.cloud \
    -e EMAIL=mail@sebastian-hutter.ch \
    sebastianhutter/certbot
```