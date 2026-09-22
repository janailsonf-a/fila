<?php

namespace App\Jobs;

use App\Models\Seat;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\DB;

/**
 * Evento vindo do serviço orders. Tenta segurar (hold) o assento
 * com lock pessimista para evitar overselling e responde de volta
 * com SeatReserved ou SeatRejected na fila do orders.
 */
class OrderCreated implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    private const HOLD_MINUTES = 10;

    public function __construct(
        public string $orderId,
        public string $sessionId,
        public string $seatId,
        public string $userId,
    ) {}

    public function handle(): void
    {
        // Resultado decidido dentro da transação; despacho feito após o commit.
        [$event, $payload] = DB::transaction(function () {
            $seat = Seat::query()
                ->where('session_id', $this->sessionId)
                ->where('seat_id', $this->seatId)
                ->lockForUpdate()
                ->first();

            if (! $seat) {
                return ['rejected', ['reason' => 'NOT_FOUND']];
            }

            if ($seat->status !== 'free') {
                return ['rejected', ['reason' => 'TAKEN']];
            }

            $holdUntil = now()->addMinutes(self::HOLD_MINUTES);

            $seat->update([
                'status' => 'held',
                'held_by_order' => $this->orderId,
                'hold_until' => $holdUntil,
            ]);

            return ['reserved', ['holdUntil' => $holdUntil->toIso8601String()]];
        });

        if ($event === 'reserved') {
            SeatReserved::dispatch($this->orderId, $this->seatId, $payload['holdUntil'])
                ->onQueue('orders');
        } else {
            SeatRejected::dispatch($this->orderId, $this->seatId, $payload['reason'])
                ->onQueue('orders');
        }
    }
}
