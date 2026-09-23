<?php

namespace Database\Seeders;

use App\Models\Seat;
use Illuminate\Database\Seeder;

class SeatSeeder extends Seeder
{
    public function run(): void
    {
        // Sessão simples usada nos testes/curl.
        foreach (['A1', 'A2', 'A3', 'A4', 'A5'] as $seatId) {
            Seat::updateOrCreate(
                ['session_id' => 'show-1', 'seat_id' => $seatId],
                ['status' => 'free'],
            );
        }

        // Sala de cinema: fileiras A–E, assentos 1–8 (40 lugares).
        foreach (range('A', 'E') as $row) {
            for ($n = 1; $n <= 8; $n++) {
                Seat::updateOrCreate(
                    ['session_id' => 'cinema-1', 'seat_id' => $row.$n],
                    ['status' => 'free'],
                );
            }
        }
    }
}
