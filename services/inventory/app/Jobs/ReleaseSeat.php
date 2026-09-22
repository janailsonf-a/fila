<?php

namespace App\Jobs;

use App\Models\Seat;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\DB;

/**
 * Compensação vinda do orders (pagamento falhou): devolve o assento
 * ao estoque, desde que ainda esteja preso a este pedido.
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
        DB::transaction(function () {
            $seat = Seat::query()
                ->where('session_id', $this->sessionId)
                ->where('seat_id', $this->seatId)
                ->lockForUpdate()
                ->first();

            if ($seat && $seat->held_by_order === $this->orderId) {
                $seat->update([
                    'status' => 'free',
                    'held_by_order' => null,
                    'hold_until' => null,
                ]);
            }
        });
    }
}
