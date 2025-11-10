import { createClient } from "npm:@supabase/supabase-js@2.30.0";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

// create_user: Creates (or ensures) a user exists in both Auth and users
Deno.serve(async (req: Request) => {
  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed. Use POST." }),
        { status: 405 },
      );
    }

    const { email, password, role } = await req.json();
    if (!email || !password || !role) {
      return new Response(
        JSON.stringify({
          error: "email, password, and role are required",
        }),
        { status: 400 },
      );
    }

    // Try to find existing user first
    const { data: existingUsers, error: listError } =
      await supabase.auth.admin.listUsers();

    if (listError) throw listError;

    let user = existingUsers.users.find((u) => u.email === email);

    if (!user) {
      // User doesn't exist -> create new Auth user
      const { data, error: userError } = await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true, // immediately confirmed for seeding
      });
      if (userError) throw userError;
      user = data.user;
      console.log(`Created new Auth user: ${email}`);
    } else {
      console.log(`Auth user already exists: ${email}`);
    }

    // Ensure a row exists in your app's users table
    const { error: upsertError } = await supabase
      .from("users")
      .upsert(
        {
          id: user.id,
          email,
          status: role,
          updated_at: new Date().toISOString(),
        },
        { onConflict: "id" } // use existing user.id if present
      );

    if (upsertError) throw upsertError;

    return new Response(JSON.stringify({ user }), { status: 200 });
  } catch (err) {
    try {
      await supabase.from("function_errors").insert([
        {
          function_name: "create_user",
          error_message: (err as Error).message,
          payload: null,
          created_at: new Date().toISOString(),
        },
      ]);
    } catch (logErr) {
      console.error("Failed to log error:", logErr);
    }

    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
    });
  }
});
