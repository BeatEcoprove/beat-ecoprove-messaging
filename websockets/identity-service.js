import api from "./api.js";

export async function login({ email, password }) {
  try {
    const response = await api.post("/login", {
      email: email,
      password: password,
    });

    return {
      userId: response.data.details.user_id,
      accessToken: response.data.access_token,
      refreshToken: response.data.refresh_token,
    };
  } catch (error) {
    console.log(error);
  }
};

export async function refreshTokens({ refreshToken }) {
  try {
    const response = await api.get("/refresh-token", {
      headers: {
        Authorization: `Bearer ${refreshToken}`,
      }
    });

    return {
      acessToken: response.data.access_token,
      refreshToken: response.data.refresh_token,
    };
  } catch (error) {
    console.log(error);
  }
};
