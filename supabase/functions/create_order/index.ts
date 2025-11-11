import { createClient } from "npm:@supabase/supabase-js@2.30.0";

const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

interface OrderItemInput {
    item_id: string;
    quantity: number;
    item_name_snapshot: string;
    price: number;
}

interface CatalogItem {
    id: string;
    stock: number;
    name: string;
}

Deno.serve(async (req: Request): Promise<Response> => {
    try {
        if (req.method !== "POST") {
            return new Response(JSON.stringify({ error: "Method not allowed. Use POST." }), { status: 405 });
        }

        const body = await req.json();
        const { user_id, shipping_address, recipient_name, status, items, created_at } = body;

        if (!user_id || !shipping_address || !recipient_name || !Array.isArray(items) || items.length === 0 || items.some((i: { item_id?: string; quantity?: number }) => !i.item_id || i.quantity == null)) {
            throw new Error(`Invalid payload: missing required field(s) or malformed items. Payload received: ${JSON.stringify(body, null, 2)}`);
        }

        // ============================
        // Step 1: Check stock availability
        // ============================
        const itemIds = items.map((i: OrderItemInput) => i.item_id);
        const { data: catalogItems, error: catalogError } = await supabase
            .from("items_catalog")
            .select("id, stock, name")
            .in("id", itemIds);
        if (catalogError) throw catalogError;

        for (const i of items as OrderItemInput[]) {
            const catalogItem = catalogItems!.find((ci: CatalogItem) => ci.id === i.item_id)!;
            if (!catalogItem) {
                throw new Error(`Item not found in catalog: ${i.item_id}`);
            }
            if (i.quantity > catalogItem.stock) {
                throw new Error(`Insufficient stock for item ${catalogItem.name} (${i.item_id}). Requested: ${i.quantity}, Available: ${catalogItem.stock}`);
            }
        }

        // ============================
        // Step 2: Check existing order for user
        // ============================
        let orderId: string;
        const { data: existingOrder, error: existingError } = await supabase
            .from("orders")
            .select("id")
            .eq("user_id", user_id)
            .eq("shipping_address", shipping_address)
            .eq("recipient_name", recipient_name)
            .maybeSingle();
        if (existingError) throw existingError;

        if (existingOrder) {
            orderId = existingOrder.id;
            console.log("Skipped existing order for user:", user_id);
        } else {
            const { data: newOrder, error: orderError } = await supabase
                .from("orders")
                .insert({
                    user_id,
                    shipping_address,
                    recipient_name,
                    status,
                    ...(created_at && { created_at: new Date(created_at).toISOString() }),
                })
                .select()
                .single();
            if (orderError) throw orderError;
            orderId = newOrder.id;
            console.log("Inserted new order for user:", user_id);
        }

        // ============================
        // Step 3: Insert order items & decrement stock
        // ============================
        for (const i of items as OrderItemInput[]) {
            const { data: existingOrderItem, error: checkItemError } = await supabase
                .from("order_items")
                .select("id")
                .eq("order_id", orderId)
                .eq("item_id", i.item_id)
                .maybeSingle();
            if (checkItemError) throw checkItemError;

            if (!existingOrderItem) {
                // Insert order item
                const { error: itemInsertError } = await supabase.from("order_items").insert([{
                    order_id: orderId,
                    item_id: i.item_id,
                    item_name_snapshot: i.item_name_snapshot,
                    quantity: i.quantity,
                    price: i.price,
                }]);
                if (itemInsertError) throw itemInsertError;
                console.log(`Added item ${i.item_id} to order ${orderId}`);

                // Decrement stock
                const catalogItem = catalogItems!.find((ci: CatalogItem) => ci.id === i.item_id)!;
                const { error: stockUpdateError } = await supabase
                    .from("items_catalog")
                    .update({ stock: catalogItem.stock - i.quantity })
                    .eq("id", i.item_id);
                if (stockUpdateError) throw stockUpdateError;
                console.log(`Updated stock for item ${i.item_id}: ${catalogItem.stock} -> ${catalogItem.stock - i.quantity}`);
            } else {
                console.log(`Skipped existing item ${i.item_id} for order ${orderId}`);
            }
        }

        // ============================
        // Step 4: Compute total of existing orders (optional)
        // ============================
        const { data: existingOrdersSumData, error: sumError } = await supabase
            .from("orders")
            .select("order_items(quantity, price)");
        if (sumError) throw sumError;

        let totalExistingOrders = 0;
        for (const order of existingOrdersSumData ?? []) {
            if (order.order_items) {
                totalExistingOrders += order.order_items.reduce((acc: number, i: { quantity: number; price: number }) => acc + i.quantity * Number(i.price), 0);
            }
        }

        return new Response(JSON.stringify({
            order_id: orderId,
            total_existing_orders_value: totalExistingOrders
        }), { status: 200 });

    } catch (err) {
        try {
            await supabase.from("function_errors").insert([{
                function_name: "create_order",
                error_message: (err as Error).message,
                payload: JSON.stringify(await req.json() ?? null),
                created_at: new Date().toISOString(),
            }]);
        } catch (logErr) { console.error("Failed to log error:", logErr); }

        return new Response(JSON.stringify({ error: (err as Error).message }), { status: 500 });
    }
});
