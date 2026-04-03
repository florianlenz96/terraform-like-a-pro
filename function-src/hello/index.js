module.exports = async function (context, req) {
  context.res = {
    status: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      message: "Hello Global Azure Bonn",
      environment: process.env.ENVIRONMENT || "unknown",
      timestamp: new Date().toISOString(),
    }),
  };
};
