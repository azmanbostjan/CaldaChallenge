// archive_old_folders/schedule.ts
import { createClient } from "npm:@supabase/supabase-js@2.30.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const _supabase = createClient(SUPABASE_URL, SERVICE_KEY);

/**
 * Registers the cron job for the archive_old_folders function.
 * In local environment, it does nothing.
 * @param cronExpression Cron syntax (default: "0 3 * * *")
 */


export async function registerArchiveCron(cronExpression = "0 3 * * *") {
  // Early exit in local env
  if (Deno.env.get("SUPABASE_ENV") === "local") {
    console.log("Skipping cron registration in local environment");
    return;
  }

  try {
    // Check if cron already exists to avoid double registration
    const existing = await _supabase
      .from("scheduler_jobs")
      .select("*")
      .eq("name", "archive_old_folders")
      .maybeSingle();

    if (existing.data) {
      console.log("Cron job for archive_old_folders already exists, skipping registration");
      return;
    }

    // Register cron via Supabase REST API
    const response = await fetch(`${SUPABASE_URL}/rest/v1/scheduler_jobs`, {
      method: "POST",
      headers: {
        "apikey": SERVICE_KEY,
        "Authorization": `Bearer ${SERVICE_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: "archive_old_folders",
        schedule: cronExpression,
        function_name: "archive_old_folders",
        retry_config: { max_retries: 0 },
        headers: {},
        payload: {},
      }),
    });

    const result = await response.json();

    if (!response.ok) {
      console.error("Failed to register archive_old_folders cron:", result);
    } else {
      console.log("Cron job for archive_old_folders registered successfully:", result);
    }
  } catch (err) {
    console.error("Error registering archive_old_folders cron:", err);
  }
}

// Optional: if this module is run directly (not imported), register immediately
if (import.meta.main) {
  registerArchiveCron().catch(console.error);
}
