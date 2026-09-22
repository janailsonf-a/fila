<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Resposta do inventory: assento reservado. Consumido por orders.
 */
class SeatReserved implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
        public string $seatId,
        public string $holdUntil,
    ) {}

    public function handle(): void
    {
        Order::whereKey($this->orderId)->update([
            'status' => 'RESERVED',
            'hold_until' => $this->holdUntil,
            'reason' => null,
        ]);
    }
}
