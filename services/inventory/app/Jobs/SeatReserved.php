<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Publicado por inventory, consumido por orders.
 * Existe aqui só para permitir o dispatch — handle() é no-op.
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
        // no-op no serviço inventory (evento é tratado no orders)
    }
}
