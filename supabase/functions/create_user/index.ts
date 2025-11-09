import { createClient } from "npm:@supabase/supabase-js@2.30.0";

const supabase = createClient(
	Deno.env.get("SUPABASE_URL")!,
	Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// create_user: Accepts a POST request with email, password, and role; creates a new Supabase Auth user, 
// inserts the user into the users table, and returns the created user object. Uses service role key for full privileges.
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

		const { data, error: userError } = await supabase.auth.admin.createUser(
			{ email, password },
		);
		if (userError) throw userError;

		const user = data.user;
		const { error: profileError } = await supabase.from("dbo.users").insert({
			id: user.id,
			email,
			status: role,
		});
		if (profileError) throw profileError;

		return new Response(JSON.stringify({ user }), { status: 200 });
	} catch (err) {
		try {
			await supabase.from("dbo.function_errors").insert([{
				function_name: "create_user",
				error_message: (err as Error).message,
				payload: null,
				created_at: new Date().toISOString(),
			}]);
		} catch (err) {
			console.error("Failed to log error:", err);
		}

		return new Response(JSON.stringify({ error: (err as Error).message }), {
			status: 500,
		});
	}
});
