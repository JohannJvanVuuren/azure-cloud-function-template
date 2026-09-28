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
  // Extract query parameters
  const name = request.query.get("name") ?? "world";
  context.log(`Hello request received for ${name}`);

  // Extract a route parameter (eg., api/users/{id}
  const userId = request.params.id;
  context.log(`Hello userId for ${userId}`);

  // Extract the json body payload
  let requestBody: any = {}
  try {
    requestBody = await request.json();
  } catch (error: unknown) {
    if (error instanceof Error) {
      console.error(error.message)
    } else {
      console.error(`Unknown error: ${error}`);
    }
  }
  const email = requestBody?.email ?? "Unknown";

  return {
    status: 200,
    jsonBody: {
      message: `Hello, ${name}! Your userId is ${userId} and email is ${email}`,
      timestamp: new Date().toISOString(),
    },
  };
}

app.http("hello", {
  methods: ["GET"],
  authLevel: "anonymous",
  handler: hello,
});
