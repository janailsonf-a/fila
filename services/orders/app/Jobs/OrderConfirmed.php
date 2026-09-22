<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Publicado por orders, consumido por notification. handle() no-op aqui.
 */
class OrderConfirmed implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
        public string $seatId,
        public string $userId,
    ) {}

    public function handle(): void
    {
        // no-op no serviço orders (tratado no notification)
    }
}
