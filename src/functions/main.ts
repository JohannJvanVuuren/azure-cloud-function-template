import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";

export async function hello(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  const name = request.query.get("name") ?? "world";

  context.log(`Hello request received for ${name}`);

  return {
    status: 200,
    jsonBody: {
      message: `Hello, ${name}!`,
      timestamp: new Date().toISOString(),
    },
  };
}

app.http("hello", {
  methods: ["GET"],
  authLevel: "anonymous",
  handler: hello,
});
