const axios = require("axios");
const fs = require("fs");

// Load the JSON payload
const payload = require("./keycloak-config.json");
const { get } = require("http");

const serverUrl =
  process.env.KEYCLOAK_SERVER_URL || "http://192.168.100.57:9088";
const adminUser = process.env.KEYCLOAK_ADMIN_USER || "admin";
const adminPassword =
  process.env.KEYCLOAK_ADMIN_PASSWORD || "dev_password_only";
const adminClientId = process.env.KEYCLOAK_ADMIN_CLIENT_ID || "admin-cli";
const realm = process.env.KEYCLOAK_REALM || "platform-realm";
const serviceAccountUser =
  process.env.KEYCLOAK_SERVICE_ACCOUNT_USER || "service-account"; // Add service account user

// Function definitions
async function getAdminToken(
  keycloakBaseUrl,
  realm,
  clientId,
  adminUser,
  adminPassword
) {
  try {
    const tokenResponse = await axios.post(
      `${keycloakBaseUrl}/realms/master/protocol/openid-connect/token`,
      new URLSearchParams({
        grant_type: "password",
        client_id: clientId,
        username: adminUser,
        password: adminPassword,
      }),
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    return tokenResponse.data.access_token;
  } catch (error) {
    console.error(
      "Error fetching admin token:",
      error.response ? error.response.data : error.message
    );
    throw error;
  }
}

async function getRoleByName(roleName, keycloakBaseUrl, realm, adminToken) {
  try {
    const response = await axios.get(
      `${keycloakBaseUrl}/admin/realms/${realm}/roles`,
      {
        headers: {
          Authorization: `Bearer ${adminToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    const role = response.data.find((r) => r.name === roleName);
    return role ? role.id : null;
  } catch (error) {
    console.error(
      "Error fetching role by name:",
      error.response ? error.response.data : error.message
    );
    throw error;
  }
}

async function getOrCreateClient(client, keycloakBaseUrl, realm, adminToken) {
  try {
    let clientResponse = await axios.get(
      `${keycloakBaseUrl}/admin/realms/${realm}/clients?clientId=${client.clientId}`,
      {
        headers: {
          Authorization: `Bearer ${adminToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    if (clientResponse.data.length > 0) {
      // Client exists, update it
      const clientId = clientResponse.data[0].id;
      await axios.put(
        `${keycloakBaseUrl}/admin/realms/${realm}/clients/${clientId}`,
        client,
        {
          headers: {
            Authorization: `Bearer ${adminToken}`,
            "Content-Type": "application/json",
          },
        }
      );
      console.log(`Updated client: ${client.clientId}`);
    } else {
      // Client does not exist, create a new one
      clientResponse = await axios.post(
        `${keycloakBaseUrl}/admin/realms/${realm}/clients`,
        client,
        {
          headers: {
            Authorization: `Bearer ${adminToken}`,
            "Content-Type": "application/json",
          },
        }
      );
      console.log(`Created client: ${client.clientId}`);
    }
    return clientResponse.data;
  } catch (error) {
    console.error(
      "Error creating or updating client:",
      error.response ? error.response.data : error.message
    );
    //throw error;
  }
}

async function processKeycloakPayload(
  payload,
  keycloakBaseUrl,
  realm,
  adminToken
) {
  const { clientScopes, defaultUser, client, defaultGroup, resetPassword } =
    payload;

  if (!clientScopes) {
    throw new Error("clientScopes is not defined in the payload");
  }

  await Promise.all(
    Object.entries(clientScopes).map(async ([scopeName, scope]) => {
      if (!scope) {
        console.error(`Scope is undefined for scopeName: ${scopeName}`);
        return;
      }

      console.log(`Processing scope: ${scopeName}`);

      const { role } = scope;

      const { name, description } = role;

      let roleId;

      try {
        const clientScopeResponse = await axios.get(
          `${keycloakBaseUrl}/admin/realms/${realm}/client-scopes`,
          {
            headers: {
              Authorization: `Bearer ${adminToken}`,
            },
          }
        );

        let clientScope = clientScopeResponse.data.find(
          (cs) => cs.name === scopeName
        );

        if (!clientScope) {
          // Client scope does not exist, create a new one
          const newClientScopeResponse = await axios.post(
            `${keycloakBaseUrl}/admin/realms/${realm}/client-scopes`,
            scope,
            {
              headers: {
                Authorization: `Bearer ${adminToken}`,
                "Content-Type": "application/json",
              },
            }
          );
          clientScope = newClientScopeResponse.data;
        }

        if (!clientScope || !clientScope.id) {
          throw new Error(`Client scope ${scopeName} does not have a valid ID`);
        } else {
          // Map scopes to the client
          const clientResponse = await getOrCreateClient(
            client,
            keycloakBaseUrl,
            realm,
            adminToken
          );
          await axios.put(
            `${keycloakBaseUrl}/admin/realms/${realm}/clients/${clientResponse[0].id}/default-client-scopes/${clientScope.id}`,
            {},
            {
              headers: {
                Authorization: `Bearer ${adminToken}`,
                "Content-Type": "application/json",
              },
            }
          );
        }
        roleId = await getRoleByName(name, keycloakBaseUrl, realm, adminToken);
        // Map the created role to the client scope
        await axios.post(
          `${keycloakBaseUrl}/admin/realms/${realm}/client-scopes/${clientScope.id}/scope-mappings/realm`,

          [{ id: roleId, name }],
          {
            headers: {
              Authorization: `Bearer ${adminToken}`,
              "Content-Type": "application/json",
            },
          }
        );
        console.log(`Mapped role ${name} to client scope ${scopeName}`);
      } catch (error) {
        console.error("Error processing scope:", error);
      }
    })
  );

  // Create or update the service-account user
  let userResponse, user, createdgroupResponse;
  try {
    let groupResponse = await axios.get(
      `${keycloakBaseUrl}/admin/realms/${realm}/groups?search=${defaultGroup}`,
      {
        headers: {
          Authorization: `Bearer ${adminToken}`,
          "Content-Type": "application/json",
        },
      }
    );
    let groupId = "";
    if (groupResponse.data.length > 0) {
      // Group exists, update it
      groupId = groupResponse.data[0].id;
      createdgroupResponse = await axios.put(
        `${keycloakBaseUrl}/admin/realms/${realm}/groups/${groupId}`,
        {
          name: defaultGroup,
        },
        {
          headers: {
            Authorization: `Bearer ${adminToken}`,
            "Content-Type": "application/json",
          },
        }
      );
    } else {
      // Group does not exist, create a new one
      createdgroupResponse = await axios.post(
        `${keycloakBaseUrl}/admin/realms/${realm}/groups`,
        {
          name: defaultGroup,
        },
        {
          headers: {
            Authorization: `Bearer ${adminToken}`,
            "Content-Type": "application/json",
          },
        }
      );
      let createdGroup = await axios.get(
        `${keycloakBaseUrl}/admin/realms/${realm}/groups?search=${defaultGroup}`,
        {
          headers: {
            Authorization: `Bearer ${adminToken}`,
            "Content-Type": "application/json",
          },
        }
      );
      console.log(`Created group: `, createdGroup);
      groupId = createdGroup.data[0].id;
    }

    const createdGroup = createdgroupResponse.data[0];
    const usersResponse = await axios.get(
      `${keycloakBaseUrl}/admin/realms/${realm}/users`,
      {
        headers: {
          Authorization: `Bearer ${adminToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    const users = usersResponse.data;
    user = users.find((u) => u.username === defaultUser.username.toLowerCase());

    if (user) {
      // User exists, update it
      const userId = user.id;
      userResponse = await axios.put(
        `${keycloakBaseUrl}/admin/realms/${realm}/users/${userId}`,
        defaultUser,
        {
          headers: {
            Authorization: `Bearer ${adminToken}`,
            "Content-Type": "application/json",
          },
        }
      );
      console.log(`Updated user: ${defaultUser.username}`);
    } else {
      // User does not exist, create a new one
      userResponse = await axios.post(
        `${keycloakBaseUrl}/admin/realms/${realm}/users`,
        defaultUser,
        {
          headers: {
            Authorization: `Bearer ${adminToken}`,
            "Content-Type": "application/json",
          },
        }
      );
      console.log(`Created user: ${defaultUser.username}`);
    }

    const createdUser = userResponse.data;
    console.log("here", user);
    // Reset the password
    const newPass = await axios.put(
      `${keycloakBaseUrl}/admin/realms/${realm}/users/${
        userResponse.id ? userResponse.id : user.id
      }/reset-password`,
      resetPassword,
      {
        headers: {
          Authorization: `Bearer ${adminToken}`,
          "Content-Type": "application/json",
        },
      }
    );
    console.log(`Reset password for user ${createdUser}`, newPass.data);
    // Step 5: Add service-account user to the group
    await axios.put(
      `${keycloakBaseUrl}/admin/realms/${realm}/users/${
        createdUser.id ? createdUser.id : user.id
      }/groups/${groupId}`,
      {},
      {
        headers: {
          Authorization: `Bearer ${adminToken}`,
          "Content-Type": "application/json",
        },
      }
    );
    console.log(`Added ${createdUser} to group ${createdgroupResponse}`);
    const uniqueRolesArray = await getUniqueRolesArray(payload);
    for (const role of uniqueRolesArray) {
      const roleID = await getRoleByName(
        role.name,
        keycloakBaseUrl,
        realm,
        adminToken
      );
      console.log(roleID);
      const roleMapping = await axios.post(
        `${keycloakBaseUrl}/admin/realms/${realm}/groups/${groupId}/role-mappings/realm`,
        [
          {
            id: roleID,
            clientRole: false,
            composite: false,
            containerId: realm,
            name: role.name,
            description: role.description,
          },
        ],
        {
          headers: {
            Authorization: `Bearer ${adminToken}`,
            "Content-Type": "application/json",
          },
        }
      );
      console.log(`Added role mapping to group ${roleMapping}`, role);
    }
  } catch (error) {
    console.error(
      "Error creating or updating user:",
      error.response ? error.response.data : error.message
    );
    throw error;
  }
}
async function getUniqueRolesArray(payload) {
  const rolesSet = new Set();
  const { clientScopes } = payload;

  for (const key in clientScopes) {
    if (clientScopes[key].role) {
      rolesSet.add(JSON.stringify(clientScopes[key].role));
    }
  }

  // Convert Set to Array and parse back to objects
  const uniqueRolesArray = Array.from(rolesSet).map((role) => JSON.parse(role));
  return uniqueRolesArray;
}
// Call the function and handle the result
async function main() {
  try {
    const adminToken = await getAdminToken(
      serverUrl,
      realm,
      adminClientId,
      adminUser,
      adminPassword
    );
    const client = payload.client;
    const createorupdateClient = await getOrCreateClient(
      client,
      serverUrl,
      realm,
      adminToken
    );
    console.log(createorupdateClient);
    const uniqueRolesArray = await getUniqueRolesArray(payload);

    for (const role of uniqueRolesArray) {
      const { name } = role;
      let roleId = await getRoleByName(name, serverUrl, realm, adminToken);

      if (roleId) {
        // Role exists, update it
        await axios.put(
          `${serverUrl}/admin/realms/${realm}/roles-by-id/${roleId}`,
          role,
          {
            headers: {
              Authorization: `Bearer ${adminToken}`,
              "Content-Type": "application/json",
            },
          }
        );
        console.log(`Updated role: ${name}`);
      } else {
        // Role does not exist, create a new one
        const roleResponse = await axios.post(
          `${serverUrl}/admin/realms/${realm}/roles`,
          role,
          {
            headers: {
              Authorization: `Bearer ${adminToken}`,
              "Content-Type": "application/json",
            },
          }
        );
        roleId = roleResponse.data.id;
        console.log(`Created role: ${name}`);
      }
    }
    await processKeycloakPayload(payload, serverUrl, realm, adminToken);
    console.log("Keycloak payload processed successfully");
  } catch (error) {
    console.error("Error processing Keycloak payload:", error);
  }
}

main();
