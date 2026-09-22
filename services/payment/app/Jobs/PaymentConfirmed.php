<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

/**
 * Publicado por payment, consumido por orders. handle() no-op aqui.
 */
class PaymentConfirmed implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public function __construct(
        public string $orderId,
    ) {}

    public function handle(): void
    {
        // no-op no serviço payment (tratado no orders)
    }
}
