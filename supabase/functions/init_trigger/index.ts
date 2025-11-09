const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

async function callInitFunction() {
  try {
    const res = await fetch(`${SUPABASE_URL}/functions/v1/init`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${SERVICE_KEY}`,
        "Content-Type": "application/json",
      },
    });

    const data = await res.json();
    if (!res.ok) {
      console.error("Init function failed:", data);
    } else {
      console.log("Init function executed successfully:", data);
    }
  } catch (err) {
    console.error("Error calling init function:", err);
  }
}

// Edge function entry point
Deno.serve(async (_req: Request) => {
  console.log("Running init_trigger...");
  await callInitFunction();
  return new Response(JSON.stringify({ status: "Init trigger completed" }), {
    status: 200,
  });
});
