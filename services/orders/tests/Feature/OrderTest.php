<?php

namespace Tests\Feature;

use App\Jobs\OrderCreated;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

class OrderTest extends TestCase
{
    use RefreshDatabase;

    public function test_creating_order_persists_pending_and_publishes_event(): void
    {
        Queue::fake();

        $response = $this->postJson('/api/orders', [
            'session_id' => 'show-1',
            'seat_id' => 'A1',
            'user_id' => 'u1',
        ]);

        $response->assertCreated();
        $this->assertDatabaseHas('orders', ['seat_id' => 'A1', 'status' => 'PENDING']);
        Queue::assertPushed(OrderCreated::class);
    }

    public function test_creating_order_requires_fields(): void
    {
        $this->postJson('/api/orders', [])->assertStatus(422);
    }
}
