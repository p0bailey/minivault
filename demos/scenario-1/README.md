This scenario comprises of having a KV secret engine with two distinctive paths accessible tree entities/users.


Entities:

**alice** has service-1 policy attached which grants read only access to secrets/services/service-1 path.


**bob** has service-1 service-2  policy attached which grants read only access to secrets/services/service-2 path.

**mike** has  services-admin policy attached which grants full access to secrets/services/* path.

Policies:

Alice and Bob:

```
path "secrets/data/services/${path}/*" {
  "capabilities" = ["read", "list"]
}

path "secrets/metadata/*" {
  capabilities = ["list"]
}

path "secrets/*" {
  "capabilities" = ["list"]
}
```

Mike
```
path "secrets/data/services/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secrets/metadata/services/*" {
  capabilities = ["list", "read"]
}

path "secrets/metadata/*" {
  capabilities = ["list"]
}

path "secrets/*" {
  "capabilities" = ["list"]
}
```

Once you have completed step 9   `make scenario_1_apply` of Quick Start, you are good to go to start to interact programmatically with MiniVault.

In a new SHELL:

Alice

Login: `vault login -method=userpass username=alice password=changeme`

```
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  xxxxxxxxxxxxxxxxxxx
token_accessor         xxxxxxxxxxxxxxxxxxx
token_duration         768h
token_renewable        true
token_policies         ["default" "service-1"]
identity_policies      []
policies               ["default" "service-1"]
token_meta_username    alice
```

Tries to retrieve secrets where the policy allows it `vault kv get  secrets/services/service-1/prod/api_key`

```
====== Metadata ======
Key              Value
---              -----
created_time     2020-10-26T21:39:01.2215369Z
deletion_time    n/a
destroyed        false
version          3

===== Data =====
Key        Value
---        -----
API_KEY    1#xyEX9*>MF3kdSZ((&M#G)t
```


Tries to retrieve secrets where the policy doesn't allow it:
`vault kv get  secrets/services/service-2/prod/api_key`

```
Error reading secrets/data/services/service-2/prod: Error making API request.


URL: GET https://vault.traefik.me:8200/v1/secrets/data/services/service-2/prod
Code: 403. Errors:

* 1 error occurred:
        * permission denied
```

Tries to write a secret in the path where the policy is assigned but doesn't have write permissions:

`vault kv put secrets/services/service-1/prod/api_key foo=bar`

```
Error writing data to secrets/data/services/service-1/prod: Error making API request.

URL: PUT https://vault.traefik.me:8200/v1/secrets/data/services/service-1/prod
Code: 403. Errors:

* 1 error occurred:
	* permission denied
```

Tries to write a secret in the path where the policy is not assigned but doesn't have write permissions:

`vault kv put secrets/services/service-2/prod/api_key foo=bar`

```
Error writing data to secrets/data/services/service-2/prod: Error making API request.

URL: PUT https://vault.traefik.me:8200/v1/secrets/data/services/service-2/prod
Code: 403. Errors:

* 1 error occurred:
	* permission denied
```

In a new SHELL:


Mike

Login: `vault login -method=userpass username=mike  password=changeme`

```
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  s.j07BNc4mZ3SvX1KmCkp5sic8
token_accessor         qrgkCD8PkyFb4cvOr1HFjo9r
token_duration         768h
token_renewable        true
token_policies         ["default" "services-admin"]
identity_policies      []
policies               ["default" "services-admin"]
token_meta_username    mike
```


Get secrets on both paths:

`vault kv get  secrets/services/service-1/prod/api_key`
```
====== Metadata ======
Key              Value
---              -----
created_time     2020-10-26T21:39:01.2215369Z
deletion_time    n/a
destroyed        false
version          3

===== Data =====
Key        Value
---        -----
API_KEY    1#xyEX9*>MF3kdSZ((&M#G)t
```

`vault kv get  secrets/services/service-2/prod/api_key`
```
====== Metadata ======
Key              Value
---              -----
created_time     2020-10-26T21:39:01.1589772Z
deletion_time    n/a
destroyed        false
version          3

===== Data =====
Key        Value
---        -----
API_KEY    Q3FOj_77Fh[sVeMxGjc]Rw1W
```


Put Secrets in bot paths:

`vault kv put secrets/services/service-1/prod/api_key bar=foo`

```
vault kv put secrets/services/service-1/prod/ bar=foo
Key              Value
---              -----
created_time     2020-10-26T21:54:37.1581017Z
deletion_time    n/a
destroyed        false
version          4
```


`vault kv put secrets/services/service-2/prod/api_key foo=bar`

```
Key              Value
---              -----
created_time     2020-10-26T21:55:16.9408492Z
deletion_time    n/a
destroyed        false
version          4
```
