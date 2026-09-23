<?php

namespace Tests\Feature;

use App\Jobs\ChargePayment;
use App\Jobs\PaymentConfirmed;
use App\Jobs\PaymentFailed;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

class ChargeTest extends TestCase
{
    use RefreshDatabase;

    public function test_successful_charge_confirms_payment(): void
    {
        Queue::fake();

        (new ChargePayment('order-1', 'A1', 'u1', 100.00))->handle();

        $this->assertDatabaseHas('payments', ['order_id' => 'order-1', 'status' => 'CONFIRMED']);
        Queue::assertPushed(PaymentConfirmed::class);
    }

    public function test_fail_user_prefix_fails_payment(): void
    {
        Queue::fake();

        (new ChargePayment('order-2', 'A1', 'failuser', 100.00))->handle();

        $this->assertDatabaseHas('payments', ['order_id' => 'order-2', 'status' => 'FAILED']);
        Queue::assertPushed(PaymentFailed::class);
    }
}
