// archive_old_folders/schedule.ts
import { createClient } from "npm:@supabase/supabase-js@2.30.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const _supabase = createClient(SUPABASE_URL, SERVICE_KEY);

/**
 * Registers the cron job for the archive_old_folders function.
 * @param cronExpression Cron syntax (e.g., "0 3 * * *" = 3AM every day)
 */
export async function registerArchiveCron(cronExpression = "0 3 * * *") {
  try {
    // The Supabase API endpoint for Scheduler jobs
    const response = await fetch(`${SUPABASE_URL}/rest/v1/scheduler_jobs`, {
      method: "POST",
      headers: {
        "apikey": SERVICE_KEY,
        "Authorization": `Bearer ${SERVICE_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        name: "archive_old_folders",
        schedule: cronExpression,
        function_name: "archive_old_folders",
        retry_config: { max_retries: 0 },
        headers: {},
        payload: {}
      })
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
