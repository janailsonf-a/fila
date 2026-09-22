<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Evento publicado por orders, consumido por inventory.
 * Aqui em orders só existe para permitir o dispatch — handle() é no-op.
 */
class OrderCreated implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
        public string $sessionId,
        public string $seatId,
        public string $userId,
    ) {}

    public function handle(): void
    {
        // no-op no serviço orders (evento é tratado no inventory)
    }
}
