import { createClient } from "npm:@supabase/supabase-js@2.30.0";

const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

interface OrderItemInput {
    item_id: string;
    quantity: number;
}

// create_order: Accepts a POST request with user_id, shipping_address, recipient_name, and order items,
// calculates the sum of all existing orders, inserts the new order and its items into the database,
// and returns the sum of other orders. Uses the service role key to bypass RLS restrictions.
Deno.serve(async (req: Request) => {
    try {
        if (req.method !== "POST") {
            return new Response(
                JSON.stringify({ error: "Method not allowed. Use POST." }),
                { status: 405 },
            );
        }

        const body = await req.json();
        const { user_id, shipping_address, recipient_name, items } = body;
        if (
            !user_id || !shipping_address || !recipient_name ||
            !Array.isArray(items)
        ) {
            return new Response(JSON.stringify({ error: "Invalid payload" }), {
                status: 400,
            });
        }

        const { data: existingItems, error: sumError } = await supabase.from(
            "order_items",
        ).select("quantity, price");
        if (sumError) throw sumError;

        const sumOfOtherOrders = existingItems?.reduce(
            (acc: number, item: { quantity: number; price: number }) =>
                acc + Number(item.price) * item.quantity,
            0,
        ) || 0;

        const { data: newOrder, error: orderError } = await supabase
            .from("orders")
            .insert({
                user_id,
                shipping_address,
                recipient_name,
                status: "basket",
            })
            .select()
            .single();
        if (orderError) throw orderError;

        const orderItemsPayload = items.map((i: OrderItemInput) => ({
            order_id: newOrder.id,
            item_id: i.item_id,
            quantity: i.quantity,
        }));

        const { error: itemsError } = await supabase.from("order_items").insert(
            orderItemsPayload,
        );
        if (itemsError) throw itemsError;

        return new Response(
            JSON.stringify({ order_id: newOrder.id, sumOfOtherOrders }),
            { status: 200 },
        );
    } catch (err) {
        try {
            await supabase.from("function_errors").insert([{
                function_name: "create_order",
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
