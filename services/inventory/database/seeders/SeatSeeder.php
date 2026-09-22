<?php

namespace Database\Seeders;

use App\Models\Seat;
use Illuminate\Database\Seeder;

class SeatSeeder extends Seeder
{
    public function run(): void
    {
        $session = 'show-1';

        foreach (['A1', 'A2', 'A3', 'A4', 'A5'] as $seatId) {
            Seat::updateOrCreate(
                ['session_id' => $session, 'seat_id' => $seatId],
                ['status' => 'free', 'held_by_order' => null, 'hold_until' => null],
            );
        }
    }
}
