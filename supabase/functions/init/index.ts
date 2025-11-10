import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2.30.0";
import { join } from "https://deno.land/std@0.203.0/path/mod.ts";
import { registerArchiveCron } from "../schedule_archive_old_folders/index.ts";

interface UserPayload {
  email: string;
  password: string;
  role: string;
}

interface OrderItemPayload {
  item_name: string;
  quantity: number;
}

interface OrderPayload {
  user_email: string;
  shipping_address: string;
  recipient_name: string;
  status: string;
  items: OrderItemPayload[];
  created_at?: string;
}

interface CatalogItem {
  id: string;
  name: string;
  price: number;
}

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase: SupabaseClient = createClient(SUPABASE_URL, SERVICE_KEY);

// Paths to payloads
const usersPayloadPath = join(Deno.cwd(), "supabase/seeds/002_insert_test_users.json");
const dataPayloadPath = join(Deno.cwd(), "supabase/seeds/001_insert_test_data.json");

// Helper to log errors
async function logError(functionName: string, errorMessage: string, payload: unknown) {
  try {
    await supabase.from("dbo.function_errors").insert([{
      function_name: functionName,
      error_message: errorMessage,
      payload: payload ? JSON.stringify(payload) : null,
      created_at: new Date().toISOString(),
    }]);
  } catch (err) {
    console.error("Failed to log error:", err);
  }
}

async function loadUsers() {
  try {
    const users: UserPayload[] = JSON.parse(await Deno.readTextFile(usersPayloadPath));

    for (const user of users) {
      const res = await fetch(`${SUPABASE_URL}/functions/v1/create_user`, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${SERVICE_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(user),
      });

      const data = await res.json();
      if (!res.ok) {
        await logError("init_loadUsers", data.error || "Unknown error", user);
        console.error("Failed to create user:", data);
      } else {
        console.log("Created user:", data.user.email);
      }
    }
  } catch (err) {
    await logError("init_loadUsers", (err as Error).message, null);
  }
}

async function loadOrders() {
  try {
    const payload: {
      catalog_items: {
        name: string;
        description: string;
        price: number;
        stock: number;
        status: string;
        created_at?: string;
      }[];
      orders: OrderPayload[];
    } = JSON.parse(await Deno.readTextFile(dataPayloadPath));

    // Insert catalog items
    for (const item of payload.catalog_items) {
      const { error } = await supabase.from("public.items_catalog").insert([{
        name: item.name,
        description: item.description || "",
        price: item.price,
        stock: item.stock,
        status: item.status,
        created_at: item.created_at ? new Date(item.created_at).toISOString() : undefined
      }]);
      if (error) {
        await logError("init_loadOrders_catalog", error.message, item);
        console.error("Failed to insert catalog item:", error.message);
      }
    }

    // Fetch catalog for enriching order items
    const { data: catalog, error: catalogError } = await supabase.from("public.items_catalog").select("*");
    if (catalogError || !catalog) {
      throw catalogError || new Error("Failed to fetch catalog after insert");
    }

    // Insert orders
    for (const order of payload.orders) {
      const { data: userRow, error: userError } = await supabase.from("dbo.users")
        .select("id").eq("email", order.user_email).single();
      if (userError || !userRow) {
        await logError("init_loadOrders_user_lookup", userError?.message || "User not found", order);
        continue;
      }

      const { data: newOrder, error: orderError } = await supabase
        .from("dbo.orders")
        .insert({
          user_id: userRow.id,
          shipping_address: order.shipping_address,
          recipient_name: order.recipient_name,
          status: order.status,
          created_at: order.created_at ? new Date(order.created_at).toISOString() : undefined
        })
        .select()
        .single();

      if (orderError || !newOrder) {
        await logError("init_loadOrders_insertOrder", orderError?.message || "Order insert failed", order);
        continue;
      }

      // Enrich order items
      const enrichedItems = order.items.map((i: OrderItemPayload) => {
        const catalogItem = catalog.find((c: CatalogItem) => c.name === i.item_name);
        if (!catalogItem) {
          throw new Error(`Catalog item not found: ${i.item_name}`);
        }

        return {
          order_id: newOrder.id,
          item_id: catalogItem.id,
          item_name_snapshot: catalogItem.name,
          quantity: i.quantity,
          price: catalogItem.price,
          created_at: order.created_at ? new Date(order.created_at).toISOString() : new Date().toISOString(),
          updated_at: order.created_at ? new Date(order.created_at).toISOString() : new Date().toISOString(),
        };
      });

      const { error: itemsError } = await supabase.from("dbo.order_items").insert(enrichedItems);
      if (itemsError) {
        await logError("init_loadOrders_insertItems", itemsError.message, enrichedItems);
        console.error("Failed to insert order items:", itemsError.message);
      } else {
        console.log("Inserted order for user:", order.user_email, "with", enrichedItems.length, "items");
      }
    }
  } catch (err) {
    await logError("init_loadOrders", (err as Error).message, null);
  }
}

// Edge function entry point
Deno.serve(async (_req: Request) => {
  try {
    // Your main initialization logic
    await loadUsers();
    await loadOrders();

    if (Deno.env.get("SUPABASE_ENV") !== "local") {
      await registerArchiveCron("*/5 * * * *");
    } else {
      console.log("Skipping cron registration in local environment");
    }

    return new Response(JSON.stringify({ status: "Seed process completed" }), { status: 200 });

  } catch (err) {
    console.error("Init function error:", err);

    // Log the error to your errors table
    try {
      await supabase.from("errors").insert({
        function_name: "init",
        message: err instanceof Error ? err.message : String(err),
        stack: err instanceof Error ? err.stack : null,
        created_at: new Date().toISOString(),
      });
    } catch (dbErr) {
      console.error("Failed to log error to database:", dbErr);
    }

    return new Response(JSON.stringify({ error: "Internal Server Error" }), { status: 500 });
  }
});