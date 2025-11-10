// functions/test_insert_user/index.ts
import { createClient } from "npm:@supabase/supabase-js@2.30.0";

// Supabase client using Service Role key
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } }
);

Deno.serve(async (_req: Request) => {
  try {
    // Hardcoded test user
    const testUser = {
      id: crypto.randomUUID(),
      email: "testuser@example.com",
      status: "Active",
      created_at: new Date().toISOString(),
    };

    const { data, error } = await supabase.from("users").insert([testUser]);

    if (error) {
      console.error("Insert failed:", error);
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    console.log("Inserted user:", data);
    return new Response(JSON.stringify({ status: "success", data }), { status: 200 });
  } catch (err) {
    console.error("Function error:", err);
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500 }
    );
  }
});
