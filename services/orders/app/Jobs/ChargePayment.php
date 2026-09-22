<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Comando publicado por orders, consumido por payment. handle() no-op aqui.
 */
class ChargePayment implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
        public string $seatId,
        public string $userId,
        public float $amount,
    ) {}

    public function handle(): void
    {
        // no-op no serviço orders (tratado no payment)
    }
}
