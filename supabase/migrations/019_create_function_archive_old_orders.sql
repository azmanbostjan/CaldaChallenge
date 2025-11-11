-- =============================================
-- Function: archive_old_orders() with total value return
-- Archives orders older than 7 days from orders -> stg_orders + stg_order_items
-- Returns the total monetary value of all archived orders
-- Logs any errors to function_errors
-- =============================================
create or replace function public.archive_old_orders()
returns numeric
language plpgsql
as $$
declare
    order_rec record;
    order_total numeric;
    total_value numeric := 0;
begin
    -- Loop through orders older than 7 days
    for order_rec in
        select *
        from public.orders o
        where o.created_at < now() - interval '7 days'
    loop
        -- Calculate total order amount
        select sum(quantity * price)
        into order_total
        from public.order_items
        where order_id = order_rec.id;

        -- Insert into stg_orders
        insert into public.stg_orders(
            id, user_id, shipping_address, recipient_name, status,
            order_total, created_at, updated_at
        ) values (
            order_rec.id,
            order_rec.user_id,
            order_rec.shipping_address,
            order_rec.recipient_name,
            order_rec.status,
            coalesce(order_total, 0),
            order_rec.created_at,
            order_rec.updated_at
        );

        -- Insert order items only if they exist
        if exists (
            select 1
            from public.order_items
            where order_id = order_rec.id
        ) then
            insert into public.stg_order_items(
                order_id, item_id, quantity, price, created_at, updated_at
            )
            select
                order_id, item_id, quantity, price, created_at, updated_at
            from public.order_items
            where order_id = order_rec.id;
        end if;

        -- Accumulate total value
        total_value := total_value + coalesce(order_total, 0);
    end loop;

    -- Delete old orders from main table
    delete from public.orders
    where created_at < now() - interval '7 days';

    -- Return total value of archived orders
    return total_value;

exception
    when others then
        -- Log the error and return 0
        insert into public.function_errors(
            function_name,
            error_message,
            payload,
            created_at
        ) values (
            'archive_old_orders',
            sqlerrm,
            null,
            now()
        );
        return 0;
end;
$$;
