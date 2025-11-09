import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2.30.0";

interface OrderItem {
    id: string;
    item_id: string;
    quantity: number;
    price: number;
    created_at: string;
    updated_at: string;
}

interface Order {
    id: string;
    user_id: string;
    shipping_address: string;
    recipient_name: string;
    status: string;
    created_at: string;
    updated_at: string;
    order_items: OrderItem[];
}

const supabase: SupabaseClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req: Request) => {
    try {
        if (req.method !== "POST") {
            return new Response(
                JSON.stringify({ error: "Method not allowed. Use POST." }),
                { status: 405 },
            );
        }

        const oneWeekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
            .toISOString();

        const { data: oldOrders, error: selectError } = await supabase
            .from("dbo.orders")
            .select(`
                id,
                user_id,
                shipping_address,
                recipient_name,
                status,
                created_at,
                updated_at,
                order_items:dbo.order_items(id, item_id, quantity, price, created_at, updated_at)
            `)
            .lt("created_at", oneWeekAgo);

        if (selectError) throw selectError;
        if (!oldOrders || oldOrders.length === 0) {
            return new Response(
                JSON.stringify({ message: "No orders to archive" }),
                { status: 200 },
            );
        }

        const { error: beginError } = await supabase.rpc("begin_transaction");
        if (beginError) throw beginError;

        for (const order of oldOrders) {
            const orderTotal = order.order_items.reduce(
                (acc: number, item: OrderItem) =>
                    acc + item.quantity * Number(item.price),
                0,
            );

            const { error: stgOrderError } = await supabase.from("stg.stg_orders")
                .insert([{
                    id: order.id,
                    user_id: order.user_id,
                    shipping_address: order.shipping_address,
                    recipient_name: order.recipient_name,
                    status: order.status,
                    order_total: orderTotal,
                    created_at: order.created_at,
                    updated_at: order.updated_at,
                }]);
            if (stgOrderError) throw stgOrderError;

            const stgItemsPayload = order.order_items.map((i: OrderItem) => ({
                order_id: order.id,
                item_id: i.item_id,
                quantity: i.quantity,
                price: i.price,
                created_at: i.created_at,
                updated_at: i.updated_at,
            }));

            const { error: stgItemsError } = await supabase.from(
                "stg.stg_order_items",
            ).insert(stgItemsPayload);
            if (stgItemsError) throw stgItemsError;
        }

        const oldOrderIds = (oldOrders as Order[]).map((o) => o.id);
        const { error: deleteError } = await supabase.from("dbo.orders").delete()
            .in("id", oldOrderIds);
        if (deleteError) throw deleteError;

        const { error: commitError } = await supabase.rpc("commit_transaction");
        if (commitError) throw commitError;

        return new Response(
            JSON.stringify({ archived_orders: oldOrders.length }),
            { status: 200 },
        );
    } catch (err) {
        // Log to function_errors table
        try {
            await supabase.from("dbo.function_errors").insert([{
                function_name: "archive_old_orders",
                error_message: (err as Error).message,
                payload: null,
                created_at: new Date().toISOString(),
            }]);
        } catch (err) {
            console.error("Failed to log error:", err);
        }

        await supabase.rpc("rollback_transaction");
        return new Response(JSON.stringify({ error: (err as Error).message }), {
            status: 500,
        });
    }
});
