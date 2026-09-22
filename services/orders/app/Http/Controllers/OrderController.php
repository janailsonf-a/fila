<?php

namespace App\Http\Controllers;

use App\Jobs\OrderCreated;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'session_id' => ['required', 'string'],
            'seat_id' => ['required', 'string'],
            'user_id' => ['required', 'string'],
        ]);

        $order = Order::create([
            'session_id' => $data['session_id'],
            'seat_id' => $data['seat_id'],
            'user_id' => $data['user_id'],
            'status' => 'PENDING',
        ]);

        // Publica evento na fila que o serviço inventory consome.
        OrderCreated::dispatch(
            $order->id,
            $order->session_id,
            $order->seat_id,
            $order->user_id,
        )->onQueue('inventory');

        return response()->json($order, 201);
    }

    public function show(string $id): JsonResponse
    {
        return response()->json(Order::findOrFail($id));
    }
}
