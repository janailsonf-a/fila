<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Log;

/**
 * Publicado por orders quando o pedido é confirmado. Consumido por notification.
 * Fase 2: só registra em log (integração Telegram/e-mail em fase futura).
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
        Log::info('Notificação: pedido confirmado', [
            'order_id' => $this->orderId,
            'seat_id' => $this->seatId,
            'user_id' => $this->userId,
        ]);
    }
}
