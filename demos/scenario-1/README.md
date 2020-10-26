This scenario comprises of having a KV secret engine with two distinctive paths accessible tree entities/users.


Entities:

**alice** has service-1 policy attached which grants read only access to secrets/services/service-1 path.


**bob** has service-1 service-2  policy attached which grants read only access to secrets/services/service-2 path.

**mike** has  services-admin policy attached which grants full access to secrets/services/* path.

Once you have completed step 9   `make scenario_1_apply` of Quick Start, you are good to go to start to interact programmatically with MiniVault.

In a new SHELL:

Alice

vault login -method=userpass username=alice password=changeme

`vault kv get  secrets/services/service-1/prod/`

```
====== Metadata ======
Key              Value
---              -----
created_time     2020-10-26T05:30:34.851533505Z

deletion_time    n/a
destroyed        false
version          2

===== Data =====
Key        Value
---        -----
API_KEY    {b)?u$60G+$9<-TQk+Zh{CwI
```

```
vault kv get  secrets/services/service-2/prod/
Error reading secrets/data/services/service-2/prod: Error making API request.


URL: GET https://vault.traefik.me:8200/v1/secrets/data/services/service-2/prod
Code: 403. Errors:

* 1 error occurred:
        * permission denied
```

Bob

vault login -method=userpass username=bob password=changeme

`vault kv get  secrets/services/service-2/prod/`

```
vault kv get  secrets/services/service-2/prod/
====== Metadata ======
Key              Value

---              -----
created_time     2020-10-26T05:30:34.951698142Z
deletion_time    n/a
destroyed        false
version          2

===== Data =====
Key        Value
---        -----
API_KEY    {b)?u$60G+$9<-TQk+Zh{CwI

```

`vault kv get  secrets/services/service-1/prod/`

```
vault kv get  secrets/services/service-1/prod/
Error reading secrets/data/services/service-1/prod: Error making API request.

URL: GET https://vault.traefik.me:8200/v1/secrets/data/services/service-1/prod
Code: 403. Errors:

* 1 error occurred:
        * permission denied

```

Mike

vault login -method=userpass username=mike  password=changeme

Get secrets:

vault kv get  secrets/services/service-1/prod/

vault kv get  secrets/services/service-2/prod/

Put Secrets:
vault kv put secrets/services/service-2/prod/ foo=bar

vault kv put secrets/services/service-1/prod/ bar=foo
