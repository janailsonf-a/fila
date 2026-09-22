<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Resposta do payment: pagamento recusado. Consumido por orders.
 * Marca PAYMENT_FAILED e COMPENSA liberando o assento no inventory.
 */
class PaymentFailed implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
        public string $reason,
    ) {}

    public function handle(): void
    {
        $order = Order::find($this->orderId);

        if (! $order) {
            return;
        }

        $order->update([
            'status' => 'PAYMENT_FAILED',
            'reason' => $this->reason,
        ]);

        // Compensação: devolve o assento ao estoque.
        ReleaseSeat::dispatch($order->id, $order->session_id, $order->seat_id)
            ->onQueue('inventory');
    }
}
