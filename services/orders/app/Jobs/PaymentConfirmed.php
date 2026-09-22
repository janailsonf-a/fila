<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Resposta do payment: pagamento aprovado. Consumido por orders.
 * Confirma o pedido e notifica.
 */
class PaymentConfirmed implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
    ) {}

    public function handle(): void
    {
        $order = Order::find($this->orderId);

        if (! $order) {
            return;
        }

        $order->update(['status' => 'CONFIRMED']);

        OrderConfirmed::dispatch($order->id, $order->seat_id, $order->user_id)
            ->onQueue('notification');
    }
}
