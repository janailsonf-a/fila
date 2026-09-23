<?php

namespace Tests\Feature;

use App\Jobs\OrderCreated;
use App\Jobs\SeatRejected;
use App\Jobs\SeatReserved;
use App\Models\Seat;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

class HoldTest extends TestCase
{
    use RefreshDatabase;

    public function test_free_seat_is_held_and_reserved(): void
    {
        Queue::fake();
        Seat::create(['session_id' => 's', 'seat_id' => 'A1', 'status' => 'free']);

        (new OrderCreated('order-1', 's', 'A1', 'u1'))->handle();

        $this->assertDatabaseHas('seats', [
            'seat_id' => 'A1',
            'status' => 'held',
            'held_by_order' => 'order-1',
        ]);
        Queue::assertPushed(SeatReserved::class);
    }

    public function test_taken_seat_is_rejected(): void
    {
        Queue::fake();
        Seat::create(['session_id' => 's', 'seat_id' => 'A1', 'status' => 'held', 'held_by_order' => 'other']);

        (new OrderCreated('order-2', 's', 'A1', 'u1'))->handle();

        Queue::assertPushed(SeatRejected::class, fn (SeatRejected $job) => $job->reason === 'TAKEN');
    }

    public function test_unknown_seat_is_rejected_as_not_found(): void
    {
        Queue::fake();

        (new OrderCreated('order-3', 's', 'ZZ', 'u1'))->handle();

        Queue::assertPushed(SeatRejected::class, fn (SeatRejected $job) => $job->reason === 'NOT_FOUND');
    }
}
