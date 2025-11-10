import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2.30.0";

interface UserPayload {
  id: string; // UUID from seed_data
  email: string;
  password: string; // still present if used for create_user
  status: "Active" | "Inactive" | "Blocked"; // enum matches DB
  name?: string; // optional, some seeds have it
}

interface OrderItemPayload {
  item_name: string;
  quantity: number;
}

interface OrderPayload {
  id: string; // UUID of the order
  user_id?: string; // optional, may come from payload
  user_email: string; // still used to look up the user
  shipping_address: string;
  recipient_name: string;
  status: "Basket" | "Ordered" | "Paid" | "Shipped" | "Received"; // match order_status enum
  items: OrderItemPayload[]; // still an array of items
  created_at?: string; // optional
}

interface CatalogItem {
  id: string;
  name: string;
  description?: string; // <- optional since DB allows NULL
  price: number;
  stock: number;
  status: string;
  created_at?: string;
}

// Supabase client with service role
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase: SupabaseClient = createClient(SUPABASE_URL, SERVICE_KEY);

/**
 * Helper to call an Edge Function with a payload
 */
async function callFunction(functionName: string, payload: unknown) {
  const res = await fetch(`${SUPABASE_URL}/functions/v1/${functionName}`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${SERVICE_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  const data = await res.json();

  if (!res.ok) {
    throw new Error(
      `Function ${functionName} failed: ${data.error || JSON.stringify(data)}`,
    );
  }

  return data;
}

/**
 * Load users from seed_data and call create_user function
 */
async function loadUsers() {
  const { data: userSeeds, error: userSeedError } = await supabase
    .from("seed_data")
    .select("payload")
    .eq("type", "user");

  if (userSeedError || !userSeeds) {
    throw userSeedError || new Error("No user seeds found");
  }

  const users: UserPayload[] = userSeeds.map((s: { payload: UserPayload }) =>
    s.payload
  );

  for (const user of users) {
    await callFunction("create_user", user);
    console.log("Created user:", user.email);
  }
}

/**
 * Load catalog items from seed_data table
 */
/**
 * Load catalog items from seed_data table (idempotent insert)
 */
async function loadCatalog(): Promise<CatalogItem[]> {
  const { data: catalogSeeds, error: catalogSeedError } = await supabase
    .from("seed_data")
    .select("payload")
    .eq("type", "catalog_item");

  if (catalogSeedError || !catalogSeeds) {
    throw catalogSeedError || new Error("No catalog seeds found");
  }

  const catalog: CatalogItem[] = [];

  for (const itemSeed of catalogSeeds) {
    const item = itemSeed.payload as CatalogItem;

    // Step 1: Check if item already exists by name
    const { data: existingItem, error: checkError } = await supabase
      .from("items_catalog")
      .select("*") // fetch all fields including DB id
      .eq("name", item.name)
      .maybeSingle();

    if (checkError) {
      throw new Error(
        `Failed to check existence of item ${item.name}: ${checkError.message}`,
      );
    }

    let catalogItem: CatalogItem;

    if (existingItem) {
      // Use the actual DB record so ID is correct
      catalogItem = existingItem;
      console.log("Skipped existing catalog item:", item.name);
    } else {
      // Insert new item and capture DB-generated ID
      const { data: insertedItem, error: insertError } = await supabase
        .from("items_catalog")
        .insert([{
          name: item.name,
          description: item.description || "",
          price: item.price,
          stock: item.stock,
          status: item.status,
          ...(item.created_at &&
            { created_at: new Date(item.created_at).toISOString() }),
        }])
        .select()
        .single();

      if (insertError) {
        throw new Error(
          `Failed to insert catalog item ${item.name}: ${insertError.message}`,
        );
      }

      catalogItem = insertedItem;
      console.log("Inserted new catalog item:", item.name);
    }

    // Push the DB record (with correct id)
    catalog.push(catalogItem);
  }

  return catalog;
}

/**
 * Load orders from seed_data and call create_order function
 */
async function loadOrders(catalog: CatalogItem[]) {
  const { data: orderSeeds, error: orderSeedError } = await supabase
    .from("seed_data")
    .select("payload")
    .eq("type", "order");

  if (orderSeedError || !orderSeeds) {
    throw orderSeedError || new Error("No order seeds found");
  }

  const orders: OrderPayload[] = orderSeeds.map((
    s: { payload: OrderPayload },
  ) => s.payload);

  for (const order of orders) {
    // Enrich order items with catalog item IDs
    const enrichedItems = order.items.map(
      (i: OrderItemPayload & { item_id?: string }) => {
        const catalogItem = catalog.find((c) => c.name === i.item_name);
        if (!catalogItem) {
          throw new Error(`Catalog item not found: ${i.item_name}`);
        }
        return {
          item_id: catalogItem.id,
          quantity: i.quantity,
          item_name_snapshot: catalogItem.name, // <-- add this
          price: catalogItem.price, // <-- add this
        };
      },
    );

    // Get user_id by email
    const { data: usersData, error: userError } = await supabase
      .from("users")
      .select("id")
      .eq("email", order.user_email)
      .maybeSingle();
    if (userError) throw userError;
    if (!usersData) throw new Error(`User not found: ${order.user_email}`);

    const userId: string = usersData.id;

    // Call create_order with payload
    await callFunction("create_order", {
      user_id: userId,
      shipping_address: order.shipping_address,
      recipient_name: order.recipient_name,
      status: order.status,
      items: enrichedItems,
      created_at: order.created_at,
    });

    console.log("Inserted order for user:", order.user_email);
  }
}

// Edge function entry point
Deno.serve(async (_req: Request) => {
  try {
    const catalog = await loadCatalog();
    await loadUsers();
    await loadOrders(catalog);

    // Register cron in production

    return new Response(JSON.stringify({ status: "Seed process completed" }), {
      status: 200,
    });
  } catch (err) {
    console.error("Init function failed:", err);

    // Log error to database
    try {
      await supabase.from("function_errors").insert([{
        function_name: "init",
        error_message: (err as Error).message,
        payload: null,
        created_at: new Date().toISOString(),
      }]);
    } catch (logErr) {
      console.error("Failed to log error:", logErr);
    }

    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
    });
  }
});
