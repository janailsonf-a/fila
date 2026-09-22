<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Comando de compensação publicado por orders, consumido por inventory.
 * handle() no-op aqui.
 */
class ReleaseSeat implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
        public string $sessionId,
        public string $seatId,
    ) {}

    public function handle(): void
    {
        // no-op no serviço orders (tratado no inventory)
    }
}
