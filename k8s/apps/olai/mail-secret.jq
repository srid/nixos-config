# Accept Google's Web client export, rejecting missing/empty credentials.
# Include the Namespace so first-time application does not depend on manifest order.
def credential:
  if type == "string" and length > 0 then .
  else error("Expected a nonempty Google Web OAuth credential") end;

(.web.client_id | credential) as $client |
(.web.client_secret | credential) as $secret |
{
  apiVersion: "v1",
  kind: "List",
  items: [
    {
      apiVersion: "v1",
      kind: "Namespace",
      metadata: {name: $namespace}
    },
    {
      apiVersion: "v1",
      kind: "Secret",
      metadata: {name: "olai-mail", namespace: $namespace},
      type: "Opaque",
      stringData: {client_id: $client, client_secret: $secret}
    }
  ]
}
