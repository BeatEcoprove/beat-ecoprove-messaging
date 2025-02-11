import { Socket } from "phoenix";
import ws from "ws";
import dotenv from "dotenv";
import { login, refreshTokens } from "./identity-service.js";

dotenv.config()

const account = {
  email: process.env.EMAIL,
  password: process.env.PASSWORD,
}

let state = {
  userId: "",
  accessToken: "",
  refreshToken: "",
};

async function replaceTokens(state) {
  const result = await refreshTokens({
    refreshToken: state.refreshToken,
  })

  return {
    ...state,
    accessToken: result.acessToken,
    refreshToken: result.refreshToken,
  }
}

// fetch account
state = await login(account);

// create socket to connect to server
const socket = new Socket(process.env.WEBSOCKETS_URL, {
  params: { userToken: state.accessToken },
  transport: ws,
});

// start connection with the server
socket.connect();

const authChannel = socket.channel(`auth:${state.userId}`);

authChannel
  .join()
  .receive("ok", (response) => {
    console.log("Connected", response);
  })
  .receive("error", async (_response) => {
    state = replaceTokens(state);
  });

authChannel.on("renew_tokens", async (_) => {
  // refresh tokens
  state = await replaceTokens(state);

  authChannel
    .push("refresh_tokens", {
      accessToken: state.accessToken,
    })
    .receive("ok", (response) => {
      console.log("Message sent successfully:", response);
    })
    .receive("error", (error) => {
      console.log("Message failed to send:", error);
    });
});
