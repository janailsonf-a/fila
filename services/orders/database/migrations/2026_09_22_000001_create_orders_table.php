<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('session_id');
            $table->string('seat_id');
            $table->string('user_id');
            $table->string('status')->default('PENDING'); // PENDING|RESERVED|REJECTED
            $table->string('reason')->nullable();
            $table->timestamp('hold_until')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
