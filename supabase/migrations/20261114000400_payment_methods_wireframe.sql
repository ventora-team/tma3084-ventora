-- Back to the wireframe's payment options (team decision, 14 Nov): cash, QR, card.
-- QR covers e-wallets (Touch 'n Go, GrabPay, Boost pay through DuitNow QR).
-- Not yet confirmed with the client.
alter table public.orders drop constraint orders_payment_method_check;
alter table public.orders add constraint orders_payment_method_check
  check (payment_method in ('cash', 'qr', 'card'));
