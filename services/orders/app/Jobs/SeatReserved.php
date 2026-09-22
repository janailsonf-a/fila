<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Resposta do inventory: assento reservado. Consumido por orders.
 * Marca RESERVED e segue a saga disparando a cobrança no payment.
 */
class SeatReserved implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    private const AMOUNT = 100.00;

    public function __construct(
        public string $orderId,
        public string $seatId,
        public string $holdUntil,
    ) {}

    public function handle(): void
    {
        $order = Order::find($this->orderId);

        if (! $order) {
            return;
        }

        $order->update([
            'status' => 'RESERVED',
            'hold_until' => $this->holdUntil,
            'reason' => null,
        ]);

        // Próximo passo da saga: cobrar.
        ChargePayment::dispatch($order->id, $order->seat_id, $order->user_id, self::AMOUNT)
            ->onQueue('payment');
    }
}
