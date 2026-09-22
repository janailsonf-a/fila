<?php

namespace App\Jobs;

use App\Models\Payment;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Str;

/**
 * Comando vindo do orders. Cobra (mock) e responde na fila do orders
 * com PaymentConfirmed ou PaymentFailed.
 *
 * Regra mock p/ demo: falha se user_id começa com "fail".
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
        $success = ! Str::startsWith($this->userId, 'fail');

        Payment::create([
            'order_id' => $this->orderId,
            'amount' => $this->amount,
            'status' => $success ? 'CONFIRMED' : 'FAILED',
            'reason' => $success ? null : 'INSUFFICIENT_FUNDS',
        ]);

        if ($success) {
            PaymentConfirmed::dispatch($this->orderId)->onQueue('orders');
        } else {
            PaymentFailed::dispatch($this->orderId, 'INSUFFICIENT_FUNDS')->onQueue('orders');
        }
    }
}
