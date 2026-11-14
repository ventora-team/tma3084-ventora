-- Payment methods the shop records (PR #18 review, 14 Nov).
-- online_banking = FPX, DuitNow Transfer, bank transfer (deposits for WhatsApp and phone orders)
-- ewallet        = Touch 'n Go, GrabPay, Boost, DuitNow QR
-- Not yet confirmed with the client; card may be dropped if the shop has no terminal.
alter table public.orders drop constraint orders_payment_method_check;
alter table public.orders add constraint orders_payment_method_check
  check (payment_method in ('cash', 'online_banking', 'ewallet', 'card'));
