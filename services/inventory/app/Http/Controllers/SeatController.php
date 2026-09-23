<?php

namespace App\Http\Controllers;

use App\Models\Seat;
use Illuminate\Http\JsonResponse;

class SeatController extends Controller
{
    public function index(string $session): JsonResponse
    {
        $seats = Seat::query()
            ->where('session_id', $session)
            ->orderBy('seat_id')
            ->get(['seat_id', 'status']);

        return response()->json($seats);
    }
}
