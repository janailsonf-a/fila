<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Resposta do inventory: assento recusado. Consumido por orders.
 */
class SeatRejected implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
        public string $seatId,
        public string $reason, // TAKEN | NOT_FOUND
    ) {}

    public function handle(): void
    {
        Order::whereKey($this->orderId)->update([
            'status' => 'REJECTED',
            'reason' => $this->reason,
        ]);
    }
}
